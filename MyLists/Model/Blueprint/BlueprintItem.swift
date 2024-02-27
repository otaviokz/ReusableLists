//
//  MetaListItem.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 26/02/2024.
//

import Foundation
import SwiftData

@Model
class BlueprintItem {
    var name: String
    private var priorityInt: Int
    var priority: Priority {
        set { priorityInt = newValue.rawValue }
        get { Priority(rawValue: priorityInt) }
    }
    
    init(name: String, priority: Priority = .low) {
        self.name = name
        self.priorityInt = priority.rawValue
    }
    
    func asToDoItem() -> ToDoItem {
        ToDoItem(name: name, priority: priority, done: false)
    }
}



extension Array where Element == BlueprintItem {
    func azSorted() -> Self {
        sorted { $0.name < $1.name }
    }
    
    func asToDoItemArray() -> [ToDoItem] {
        map { $0.asToDoItem() }
    }
}

