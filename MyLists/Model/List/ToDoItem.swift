//
//  Item.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import Foundation
import SwiftData

@Model
class ToDoItem: ObservableObject {
    var name: String
    var done: Bool
    var priority: Priority {
        set { priorityInt = newValue.rawValue }
        get { Priority(rawValue: priorityInt) }
    }
    private var priorityInt: Int
    
    init(name: String = "", priority: Priority = .low, done: Bool = false) {
        self.name = name
        self.priorityInt = priority.rawValue
        self.done = done
    }
}

enum SortType {
    case doneFirst
    case doneLast
    case priority
    case alphabetic
}

extension Array where Element == ToDoItem {
    func sorted(type: SortType) -> Self {
        switch type {
            case .doneFirst: return sortedByDoneFirst
            case .doneLast: return sortedByDoneLast
            case .priority: return sortedByPriority
            case .alphabetic: return sortedByName
        }
    }
    
    var sortedByDoneFirst: Self {
        sorted {
            if $0.done != $1.done {
                return $0.done.sortValue > $1.done.sortValue
            } else if $0.priority.rawValue != $1.priority.rawValue {
                return $0.priority.rawValue > $1.priority.rawValue
            } else {
                return $0.name < $1.name
            }
        }
    }
    
    var sortedByDoneLast: Self {
        sorted {
            if $0.done != $1.done {
                return $0.done.sortValue < $1.done.sortValue
            } else if $0.priority.rawValue != $1.priority.rawValue {
                return $0.priority.rawValue > $1.priority.rawValue
            } else {
                return $0.name < $1.name
            }
        }
    }
    
    var sortedByPriority: Self {
        sorted {
            if $0.priority.rawValue != $1.priority.rawValue {
                return $0.priority.rawValue > $1.priority.rawValue
            } else {
                return $0.name < $1.name
            }
        }
    }
    
    var sortedByName: Self {
        sorted {
            $0.name < $1.name
        }
    }
}

private extension Bool {
    var sortValue: Int {
        self ? 1 : 0
    }
}
