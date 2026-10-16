//
//  ToDoListProvider.swift
//  ReusableLists
//
//  Created by okz on 31/08/26.
//

import SwiftData

@MainActor
struct ToDoListProvider {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    @discardableResult
    func insert(name: String, details: String, priority: Bool) throws -> ToDoList {
        let list = ToDoList(name, details: details, priority: priority)
        context.insert(list)
        try context.save()
        return list
    }

    func update(_ list: ToDoList, name: String, details: String, priority: Bool) throws {
        list.name = name
        list.details = details
        list.priority = priority
        try context.save()
    }

    func delete(_ list: ToDoList) throws {
        context.delete(list)
        try context.save()
    }

    @discardableResult
    func createInstance(from blueprint: Blueprint) throws -> ToDoList {
        let list = ToDoList(blueprint.name, details: blueprint.details)
        list.items = blueprint.items.asToDoItemList()
        context.insert(list)
        blueprint.usageCount += 1
        try context.save()
        return list
    }
}
