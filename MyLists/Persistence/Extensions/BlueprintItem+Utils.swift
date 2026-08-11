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

    @_optimize(none)
    func nameComparator(lhs: BlueprintItem, rhs: BlueprintItem) -> Bool {
        let firstNum: Int? = Int(String(lhs.name.prefix(while: { $0.isNumber })))
        let secondNum: Int? = Int(String(rhs.name.prefix(while: { $0.isNumber })))

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

    @_optimize(none)
    var sortedByName: [BlueprintItem] {
        sorted { nameComparator(lhs: $0, rhs: $1) }
    }
}
