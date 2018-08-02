//
//  PersistentController.swift
//  ToDoList
//
//  Created by Shawn Wu on 7/29/18.
//  Copyright © 2018 Shawn Wu. All rights reserved.
//

import CoreData

class PersistentController: NSObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func restore() -> [Event] {
        let request: NSFetchRequest<EventEntity> = NSFetchRequest(entityName: "EventEntity")
        if let events = try? context.fetch(request) {
            return events.map {
                return Event(content: $0.content ?? "",
                             time: $0.time! as Date,
                             category: EventCategory(rawValue: Int($0.category))!,
                             id: $0.id ?? UUID(),
                             state: EventState(rawValue: Int($0.state))!)
            }
        }
        return [Event]()
    }
    
    private func exist(event: Event) -> EventEntity? {
        let request: NSFetchRequest<EventEntity> = NSFetchRequest(entityName: "EventEntity")
        request.predicate = NSPredicate(format: "id = %@", event.id.uuidString)
        if let eventEntity = try? context.fetch(request).first {
            return eventEntity
        }
        return nil
    }
    
    func createOrUpdate(event: Event) {
        if let eventEntity = exist(event: event) {
            update(eventEntity: eventEntity, with: event)
        } else {
            create(with: event)
        }
        try? context.save()
    }
    
    private func update(eventEntity: EventEntity, with event: Event) {
        eventEntity.category = Int16(event.category.rawValue)
        eventEntity.state = Int16(event.state.rawValue)
        eventEntity.content = event.content
        eventEntity.id = event.id
        eventEntity.time = event.time as NSDate
    }
    
    private func create(with event: Event) {
        if let eventEntity = NSEntityDescription.insertNewObject(forEntityName: "EventEntity", into: context) as? EventEntity {
            update(eventEntity: eventEntity, with: event)
        }
    }
}
