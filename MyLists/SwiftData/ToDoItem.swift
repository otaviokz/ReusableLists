//
//  Item.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import Foundation
import SwiftData

@Model
final class ToDoItem: ObservableObject {
    var name: String
    var done: Bool
    
    init(name: String = "", done: Bool = false) {
        self.name = name
        self.done = done
    }
}

enum SortType {
    case doneFirst
    case doneLast
    case alphabetic
}
extension ToDoItem {
    var asBlueprintItem: BlueprintItem {
        BlueprintItem(name: name)
    }
}

extension Array where Element == ToDoItem {
    func sorted(type: SortType) -> Self {
        switch type {
            case .doneFirst: return sortedByDoneFirst
            case .doneLast: return sortedByDoneLast
            case .alphabetic: return sortedByName
        }
    }
    
    var sortedByDoneFirst: [ToDoItem] {
        sorted {
            if $0.done != $1.done {
                $0.done.sortValue > $1.done.sortValue
            } else {
                $0.name < $1.name
            }
        }
    }
    
    var sortedByDoneLast: Self {
        sorted {
            if $0.done != $1.done {
                $0.done.sortValue < $1.done.sortValue
            } else {
                $0.name < $1.name
            }
        }
    }
    
    var sortedByName: Self {
        sorted {
            $0.name < $1.name
        }
    }
    
    func asBlueprintItems() -> [BlueprintItem] {
        map { $0.asBlueprintItem }
    }
    
    var doneItems: [ToDoItem] {
        filter { $0.done }
    }
}

fileprivate extension Bool {
    var sortValue: Int {
        self ? 1 : 0
    }
}
