//
//  BlueprintItemProvider.swift
//  ReusableLists
//
//  Created by okz on 31/08/26.
//

import SwiftData

@MainActor
struct BlueprintItemProvider {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func insert(_ items: [(name: String, priority: Bool)], into blueprint: Blueprint) throws {
        for item in items {
            let newItem = BlueprintItem(item.name, priority: item.priority)
            blueprint.items.append(newItem)
            context.insert(newItem)
        }
        try context.save()
    }

    func delete(_ item: BlueprintItem, from blueprint: Blueprint) throws {
        blueprint.items = blueprint.items.filter { $0 != item }
        context.delete(item)
        try context.save()
    }

    /// Persists edits already applied directly to a fetched BlueprintItem's properties.
    func save() throws {
        try context.save()
    }
}
