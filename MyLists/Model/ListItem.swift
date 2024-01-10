//
//  Item.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import Foundation
import SwiftData

@Model
class ListItem: ObservableObject {
    var name: String
    private var priorityInt: Int
    var done: Bool
    
    var priority: Priority {
        set {
            priorityInt = newValue.rawValue
        }
        get {
            Priority(rawValue: priorityInt)
        }
    }
    
    init(name: String = "", priority: Priority = .low, done: Bool = false) {
        self.name = name
        self.priorityInt = priority.rawValue
        self.done = done
    }
}
