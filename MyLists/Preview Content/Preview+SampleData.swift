//
//  Preview+SampleData.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 08/10/2024.
//

import SwiftUI
import SwiftData

extension ToDoList {
    convenience init(_ name: String = "", details: String = "", items: [ToDoItem]) {
        self.init(name: name, details: details)
        self.items = items
    }
}
