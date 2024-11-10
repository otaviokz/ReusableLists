//
//  ToDoList.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import Foundation
import SwiftData

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
