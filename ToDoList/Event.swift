//
//  Event.swift
//  ToDoList
//
//  Created by Shawn Wu on 8/1/18.
//  Copyright © 2018 Shawn Wu. All rights reserved.
//
import Foundation

enum EventState: Int {
    case complete
    case overdue
    case waiting
}

enum EventCategory: Int {
    case lifeStyle
    case workout
    case money
    case grocery
    case study
    case other
    
    var stringValue: String {
        switch self {
        case .lifeStyle:
            return "lifestyle"
        case .grocery:
            return "grocery"
        case .money:
            return "money"
        case .study:
            return "study"
        case .workout:
            return "workout"
        case .other:
            return "other"
        }
    }
}

class Event: NSObject {
    var state: EventState
    var content: String
    var time = Date()
    let id: UUID
    let category: EventCategory
    
    init(content: String, time: Date, category: EventCategory = .other, id: UUID = UUID(), state: EventState = .waiting) {
        self.content = content
        self.time = time
        self.category = category
        self.id = id
        self.state = state
    }
}
