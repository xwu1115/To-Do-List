//
//  ViewController.swift
//  ToDoList
//
//  Created by Shawn Wu on 7/16/18.
//  Copyright © 2018 Shawn Wu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import UserNotifications

class ViewController: UIViewController, SaveEventProtocol {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewEventBtn: UIBarButtonItem!
    
    private let disposeBag = DisposeBag()
    private var vm = Variable<[ViewModel]>([])
    private var eventsManager: EventManager?
    private var backgroundTask: UIBackgroundTaskIdentifier = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpEventManager()
        restoreData()
        setUpTableView()
        setUpBackgroundTask()
        setUpNotification()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SetUpViewController {
            vc.delegate = self
        }
    }
    
    private func setUpEventManager() {
        eventsManager = EventManager()
        eventsManager?.trigger.asObserver().subscribe(onNext: { event in
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = event.category.stringValue
            content.body = event.content
            let identifier = "ToDoList"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request, withCompletionHandler:nil)
        }).disposed(by: disposeBag)
    }
    
    private func setUpNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: NSNotification.Name(rawValue: "appWillTerminate"), object: nil)
    }
    
    @objc private func appWillTerminate() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.eventsManager?.allEvents.value.forEach {
            appDelegate.persistentController?.createOrUpdate(event: $0)
        }
    }
    
    private func restoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let events = appDelegate.persistentController?.restore() {
            events.forEach {
                eventsManager?.add(event: $0)
            }
        }
    }
    
    private func setUpTableView() {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        
        eventsManager?.allEvents.asObservable().bind(to: tableView.rx.items(cellIdentifier: "event", cellType: EventViewCell.self)) { row, item, cell in
            cell.configure(item: item)
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe { indexPath in
            if let row = indexPath.element?.row, let event = self.eventsManager?.allEvents.value[row] {
                self.eventsManager?.finish(event: event)
            }
        }.disposed(by: disposeBag)
    }
    
    private func setUpBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func didSaveEvent(_ event: Event) {
        eventsManager?.add(event: event)
    }
}

class ViewModel: NSObject {
    var content: String {
        return event.content
    }
    
    private let event: Event
    
    init(event: Event) {
        self.event = event
    }
}
