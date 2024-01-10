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

enum SortType {
    case doneFirst
    case doneLast
    case priority
}

extension Array where Element == ListItem {
    func sorted(type: SortType) -> Self {
        switch type {
            case .doneFirst: return sortedByDoneFirst
            case .doneLast: return sortedByDoneLast
            case .priority: return sortedByPriority
        }
    }
    
    var sortedByDoneFirst: Self {
        sorted {
            if $0.done != $1.done {
                return $0.done.intValue > $1.done.intValue
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
                return $0.done.intValue < $1.done.intValue
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
}

private extension Bool {
    var intValue: Int {
        self ? 1 : 0
    }
}
