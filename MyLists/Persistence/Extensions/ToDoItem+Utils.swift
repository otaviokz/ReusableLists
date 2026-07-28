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
    case priority
}

extension Array where Element == ToDoItem {
    func sorted(by sortType: SortType) -> [ToDoItem] {
        return switch sortType {
            case .doneFirst: sortedByDoneFirst
            case .doneLast: sortedByDoneLast
            case .alphabetic: sortedByName
            case .priority: sortedByPriority
        }
    }
    
    var sortedByDoneFirst: [ToDoItem] {
        sortedByName.sorted { $0.done && !$1.done }
    }
    
    var sortedByDoneLast: [ToDoItem] {
        sortedByName.sorted { !$0.done && $1.done }
    }

    func nameComparator(lhs: ToDoItem, rhs: ToDoItem) -> Bool {
        let firstNum: Int? = Int(lhs.name.prefix(while: { $0.isNumber }))
        let secondNum: Int? = Int(rhs.name.prefix(while: { $0.isNumber }))

        guard firstNum != nil || secondNum != nil else {
            return lhs.name < rhs.name
        }

        return if let firstNum, let secondNum {
            firstNum == secondNum ? lhs.name < rhs.name : firstNum < secondNum
        } else if firstNum != nil {
            true
        } else {
            false
        }
    }

    var sortedByName: [ToDoItem] {
        sorted { nameComparator(lhs: $0, rhs: $1) }
    }

    var sortedByPriority: [ToDoItem] {
        sortedByName.sorted { $0.priority && !$1.priority }
    }

    var sortedByPriorityAndNameKeepingDoneOrder: [ToDoItem] {
        sorted {
            if $0.done == $1.done && $0.priority == $1.priority {
                return nameComparator(lhs: $0, rhs: $1)
            } else if $0.done == $1.done && $0.priority != $1.priority {
                return $0.priority && !$1.priority
            } else {
                return false
            }
        }
    }
    
    var doneItems: [ToDoItem] {
        filter { $0.done }
    }
}
