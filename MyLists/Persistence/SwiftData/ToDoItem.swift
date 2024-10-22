//
//  Item.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import Foundation
import SwiftData

@Model
final class ToDoItem: ObservableObject {
    var name: String
    var done: Bool = false
    
    init(_ name: String = "", done: Bool = false) {
        self.name = name
        self.done = done
    }
}

enum SortType {
    case doneFirst
    case todoFirst
    case alphabetic
}

extension Array where Element == ToDoItem {
    func sorted(by sortType: SortType) -> [ToDoItem] {
        switch sortType {
            case .doneFirst: sortedByDoneFirst
            case .todoFirst: sortedByTodoFirst
            case .alphabetic: sortedByName
        }
    }
    
    var sortedByDoneFirst: [ToDoItem] {
        sorted { $0.done.sortValue > $1.done.sortValue }.sortedByNameKeepingStatus
    }
    
    var sortedByTodoFirst: [ToDoItem] {
        sorted { $0.done.sortValue < $1.done.sortValue }.sortedByNameKeepingStatus
    }
    
    var sortedByName: [ToDoItem] {
        sorted { $0.name < $1.name }
    }
    
    /// Only switch element places if both have same "done" value but different names
    var sortedByNameKeepingStatus: [ToDoItem] {
        sorted { if $0.done == $1.done { $0.name < $1.name } else { false } }
    }
    
    var doneItems: [ToDoItem] {
        filter { $0.done }
    }
}

fileprivate extension Bool {
    var sortValue: Int { self ? 1 : 0 }
}
