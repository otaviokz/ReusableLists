//
//  Item.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import Foundation
import SwiftData

enum SortType {
    case doneFirst
    case doneLast
    case alphabetic
}

extension Array where Element == ToDoItem {
    func sorted(by sortType: SortType) -> [ToDoItem] {
        switch sortType {
        case .doneFirst: sortedByDoneFirst.sortedByPriorityAndNameKeepingDoneOrder
        case .doneLast: sortedByDoneLast.sortedByPriorityAndNameKeepingDoneOrder
            case .alphabetic: sortedByName
        }
    }
    
    var sortedByDoneFirst: [ToDoItem] {
        sorted { $0.done.sortValue > $1.done.sortValue }
    }
    
    var sortedByDoneLast: [ToDoItem] {
        sortedByDoneFirst.reversed()
    }
    
    var sortedByName: [ToDoItem] {
        sorted { $0.name < $1.name }
    }
    
//    /// Only switch element places if both have same "done" value but different names
//    private var sortedByNameKeepingStatus: [ToDoItem] {
//        sorted { if $0.done == $1.done { $0.name < $1.name } else { false } }
//    }
    
    var sortedByPriorityAndNameKeepingDoneOrder: [ToDoItem] {
        sorted {
            if $0.done == $1.done {
                if $0.priority == $1.priority {
                    $0.name < $1.name
                } else {
                    $0.priority.sortValue > $1.priority.sortValue
                }
            } else {
                false
            }
        }
    }
    
    var doneItems: [ToDoItem] {
        filter { $0.done }
    }
}

fileprivate extension Bool {
    var sortValue: Int { self ? 1 : 0 }
}
