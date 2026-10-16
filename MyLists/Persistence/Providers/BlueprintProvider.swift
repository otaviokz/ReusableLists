//
//  BlueprintProvider.swift
//  ReusableLists
//
//  Created by okz on 31/08/26.
//

import SwiftData

@MainActor
struct BlueprintProvider {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    @discardableResult
    func insert(name: String, details: String) throws -> Blueprint {
        let blueprint = Blueprint(name, details: details)
        context.insert(blueprint)
        try context.save()
        return blueprint
    }

    func update(_ blueprint: Blueprint, name: String, details: String) throws {
        blueprint.name = name
        blueprint.details = details
        try context.save()
    }

    func delete(_ blueprint: Blueprint) throws {
        context.delete(blueprint)
        try context.save()
    }
}
