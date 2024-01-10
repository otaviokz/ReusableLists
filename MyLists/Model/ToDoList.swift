//
//  List.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import Foundation
import SwiftData

@Model
class ToDoList: ObservableObject {
    var name: String
    var details: String
    let creationDate: Date
    @Relationship(deleteRule: .cascade) var items: [ListItem] = []
    var sortedItems: [ListItem] {
        items.sortedByDoneFirst
    }
    
    init(name: String = "", details: String = "") {
        self.name = name
        self.creationDate = .now
        self.details = details
    }
}

extension ToDoList {
    var completion: Double {
        min(1, Double(items.filter { $0.done }.count) / Double(items.count))
    }
}
