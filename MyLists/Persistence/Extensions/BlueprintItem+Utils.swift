//
//  MetaListItem.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 26/02/2024.
//

import Foundation
import SwiftUI
import SwiftData

extension Array where Element == BlueprintItem {
    func asToDoItemList() -> [ToDoItem] {
        map { $0.asToDoItem() }
    }
    
    var sortedByPriorityAndName: [Element] {
        var prioritised = sorted { !$0.priority && $1.priority }
        return prioritised.sorted { if $0.priority == $1.priority { $0.name < $1.name } else { false } }
    }
}
