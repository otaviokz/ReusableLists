//
//  MetaListItem.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 26/02/2024.
//

import SwiftUI
import SwiftData

@Model
final class BlueprintItem: ObservableObject {
    var name: String
    
    init(name: String) {
        self.name = name
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

