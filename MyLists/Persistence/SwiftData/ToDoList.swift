//
//  ToDoList.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import Foundation
import SwiftData

@Model
final class ToDoList: ObservableObject {
    var name: String
    var details: String
    var creationDate: Date
    @Relationship(deleteRule: .cascade) var items: [ToDoItem] = []
    
    init(_ name: String = "", details: String = "") {
        self.name = name
        self.creationDate = .now
        self.details = details
    }
}

extension ToDoList {
    var completion: Double {
        guard items.count > 0 else { return 0 }
        return min(1, Double(doneItems.count) / Double(items.count))
    }
    
    var doneItems: [ToDoItem] {
        items.doneItems
    }
    
    var isDone: Bool {
        doneItems.count == items.count
    }
    
    var progress: Double {
        Double(doneItems.count) / Double(items.count)
    }
    
    static var placeholderList: ToDoList {
        ToDoList("Placeholder")
    }
}
