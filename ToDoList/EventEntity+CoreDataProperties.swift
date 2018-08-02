//
//  EventEntity+CoreDataProperties.swift
//  
//
//  Created by Shawn Wu on 7/29/18.
//
//

import Foundation
import CoreData


extension EventEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventEntity> {
        return NSFetchRequest<EventEntity>(entityName: "EventEntity")
    }

    @NSManaged public var time: NSDate?
    @NSManaged public var id: UUID?
    @NSManaged public var content: String?
    @NSManaged public var category: Int16
    @NSManaged public var state: Int16

}
