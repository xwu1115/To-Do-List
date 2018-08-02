//
//  EventManager.swift
//  ToDoList
//
//  Created by Shawn Wu on 7/16/18.
//  Copyright © 2018 Shawn Wu. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class EventManager: NSObject {
    private let queue = DispatchQueue(label: "event manager queue")
    private var triggeredEvents: Variable<[Event]> = Variable<[Event]>([])
    private var ongoingEvents: Variable<[Event]> = Variable<[Event]>([])
    private(set) var trigger: PublishSubject<Event> = PublishSubject()
    private(set) var allEvents: Variable<[Event]> = Variable<[Event]>([])
    private var activeEvent: Event?
    private var timer: Timer?
    private let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
        let combine = Observable.combineLatest(ongoingEvents.asObservable(), triggeredEvents.asObservable())
        combine.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            self.queue.async { [weak self] in
                guard let `self` = self else { return }
                self.allEvents.value = self.triggeredEvents.value + self.ongoingEvents.value
                self.allEvents.value = self.allEvents.value.sorted { $0.time < $1.time }
            }
        }.disposed(by: disposeBag)
    }
    
    func add(event: Event) {
        queue.async { [weak self] in
            guard let `self` = self else { return }
        
            switch event.state {
            case .waiting:
                self.addToOngoingEvents(event: event)
            default:
                self.addToTriggeredEvents(event: event)
            }
        }
    }
    
    func finish(event: Event, passDue: Bool = false) {
        queue.async { [weak self] in
            guard let `self` = self else { return }
            
            if self.activeEvent?.id == event.id {
                self.invalidate()
                self.moveToTriggered(passDue: passDue)
                self.start(self.ongoingEvents.value.first)
            } else {
                // move selected event to triggered, no affect on current active event
                if let found = (self.ongoingEvents.value.filter { $0.id == event.id }).first, let idx = self.ongoingEvents.value.index(of: found) {
                    self.moveToTriggered(idx: idx, passDue: passDue)
                }
            }
        }
    }
    
    private func addToOngoingEvents(event: Event) {
        ongoingEvents.value.append(event)
        if activeEvent == nil {
            start(ongoingEvents.value.first)
        } else {
            ongoingEvents.value = ongoingEvents.value.sorted { $0.time < $1.time }
            if activeEvent?.id != ongoingEvents.value.first?.id {
                interrupt()
            }
        }
    }
    
    private func addToTriggeredEvents(event: Event) {
        triggeredEvents.value.append(event)
        triggeredEvents.value = triggeredEvents.value.sorted { $0.time < $1.time }
    }
    
    private func start(_ event: Event?) {
        guard let e = event else {
            return
        }
        print("start event: \(e.id)")
        activeEvent = e
        let timeSinceNow = e.time.timeIntervalSinceNow
        
        let timer = Timer(timeInterval: timeSinceNow, target: self, selector: #selector(timerFires(timer:)), userInfo: nil, repeats: false)
        self.timer = timer
        let runLoop = RunLoop.main
        runLoop.add(timer, forMode: .commonModes)
    }
    
    private func interrupt() {
        print("queue interrupted")
        invalidate()
        start(ongoingEvents.value.first)
    }
    
    private func invalidate() {
        timer?.invalidate()
        timer = nil
        activeEvent = nil
    }
    
    @objc private func timerFires(timer: Timer) {
        queue.async { [weak self] in
            guard let `self` = self else { return }
            
            self.trigger.onNext(self.activeEvent!)
            self.finish(event: self.activeEvent!, passDue: true)
        }
    }
    
    private func moveToTriggered(idx: Int = 0, passDue: Bool = false) {
        let e = ongoingEvents.value.remove(at: idx)
        e.state = passDue ? .overdue : .complete
        print("complete event: \(e.id), state: \(e.state)")
        addToTriggeredEvents(event: e)
    }
}
