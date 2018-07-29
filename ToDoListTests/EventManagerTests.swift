//
//  EventManagerTests.swift
//  ToDoListTests
//
//  Created by Shawn Wu on 7/26/18.
//  Copyright © 2018 Shawn Wu. All rights reserved.
//

@testable import ToDoList
import Nimble
import Quick

class EventManagerTests: QuickSpec {
    override func spec() {
        super.spec()
        
        var manager: EventManager!
        
        beforeEach {
            manager = EventManager()
        }
        
        afterEach {
            manager = nil
        }
        
        it("single") {
            let e = Event(title: "test", content: "test", time: Date(timeIntervalSinceNow: 0.1))
            manager.add(event: e)
            expect(manager.allEvents.value.count).toEventually(equal(1), timeout: 0.5)
            expect(manager.allEvents.value[0].state).toEventually(equal(EventState.overdue), timeout: 1)
        }
        
        it("finish") {
            let e = Event(title: "test", content: "test", time: Date(timeIntervalSinceNow: 2.0))
            manager.add(event: e)
            manager.finish(event: e)
            expect(manager.allEvents.value.count).toEventually(equal(1), timeout: 0.5)
            expect(manager.allEvents.value[0].state).toEventually(equal(EventState.complete), timeout: 0.5)
        }
        
        it("order") {
            let e1 = Event(title: "test", content: "test", time: Date(timeIntervalSinceNow: 0.1))
            let e2 = Event(title: "test", content: "test", time: Date(timeIntervalSinceNow: 1.5))
            manager.add(event: e1)
            manager.add(event: e2)
            expect(manager.allEvents.value.count).toEventually(equal(2), timeout: 0.5)
            expect(manager.allEvents.value[0].state).toEventually(equal(EventState.overdue), timeout: 1)
            expect(manager.allEvents.value[1].state).toEventually(equal(EventState.waiting), timeout: 1.1)
        }
        
        it("interrupt") {
            let e1 = Event(title: "test", content: "test", time: Date(timeIntervalSinceNow: 0.1))
            let e2 = Event(title: "test", content: "test", time: Date(timeIntervalSinceNow: 1.5))
            let e3 = Event(title: "test", content: "test", time: Date(timeIntervalSinceNow: 1.3))
            manager.add(event: e2)
            manager.add(event: e1)
            manager.add(event: e3)
            expect(manager.allEvents.value.count).toEventually(equal(3), timeout: 0.5)
            expect(manager.allEvents.value[0].state).toEventually(equal(EventState.overdue), timeout: 1)
            expect(manager.allEvents.value[1].state).toEventually(equal(EventState.waiting), timeout: 1.1)
            expect(manager.allEvents.value[2].state).toEventually(equal(EventState.waiting), timeout: 1.2)
        }
    }
}
