//
//  ViewModel.swift
//  ToDoList
//
//  Created by Shawn Wu on 7/16/18.
//  Copyright © 2018 Shawn Wu. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa

class ViewModel: NSObject {
    var title: String {
        return event.title
    }
    
    var content: String {
        return event.content
    }
    
    private let event: Event
    
    init(event: Event) {
        self.event = event
    }
}
