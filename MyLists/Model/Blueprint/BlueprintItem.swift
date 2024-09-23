//
//  MetaListItem.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 26/02/2024.
//

import SwiftUI
import SwiftData

@Model
class BlueprintItem: Nameable {
    typealias Nameable = BlueprintItem
    
    var name: String
    private var priorityInt: Int = 0//
    var priority: Priority {
        set { priorityInt = newValue.rawValue }
        get { Priority(rawValue: priorityInt) }
    }
    
    init(name: String) {
        self.name = name
        self.priority = .low
    }
    
    func asToDoItem() -> ToDoItem {
        ToDoItem(name: name, done: false)
    }
}

extension Array where Element == BlueprintItem {
    var sortedByName: [BlueprintItem] {
        sorted { $0.name < $1.name }
    }
    
    func asToDoItemList() -> [ToDoItem] {
        map { $0.asToDoItem() }
    }
}

