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
    
    init(name: String = "", details: String = "") {
        self.name = name
        self.creationDate = .now
        self.details = details
    }
}
