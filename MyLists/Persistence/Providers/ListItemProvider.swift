//
//  ListItemProvider.swift
//  ReusableLists
//
//  Created by okz on 31/08/26.
//

import SwiftData

@MainActor
struct ListItemProvider {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func insert(_ items: [(name: String, priority: Bool)], into list: ToDoList) throws {
        for item in items {
            let newItem = ToDoItem(item.name, priority: item.priority)
            list.items.append(newItem)
            context.insert(newItem)
        }
        try context.save()
    }

    func toggleDone(_ item: ToDoItem) throws {
        item.done.toggle()
        try context.save()
    }

    func delete(_ item: ToDoItem, from list: ToDoList) throws {
        list.items = list.items.filter { $0 != item }
        context.delete(item)
        try context.save()
    }

    /// Persists edits already applied directly to a fetched ToDoItem's properties.
    func save() throws {
        try context.save()
    }
}
