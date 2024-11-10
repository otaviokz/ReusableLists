//
//  MetaListItem.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 26/02/2024.
//

import SwiftUI
import SwiftData

extension Array where Element == BlueprintItem {
    var sortedByName: [BlueprintItem] {
        sorted { $0.name < $1.name }
    }
    
    func asToDoItemList() -> [ToDoItem] {
        map { $0.asToDoItem() }
    }
}
