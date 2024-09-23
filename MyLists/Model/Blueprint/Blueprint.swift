//
//  MetaList.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 26/02/2024.
//

import Foundation
import SwiftData

@Model
class Blueprint: ObservableObject, NameAndDetailsType {
    typealias Nameable = Blueprint
    
    var name: String
    var details: String
    private var priorityInt: Int = 1
    var priority: Priority {
        set { priorityInt = newValue.rawValue }
        get { Priority(rawValue: priorityInt) }
    }

    @Relationship(deleteRule: .cascade) var items: [BlueprintItem] = []
    @Relationship(deleteRule: .nullify) var list: ToDoList?
    
    init(name: String, details: String = "") {
        self.name = name.trimmingSpaces
        self.details = details.trimmingSpaces
    }
}
