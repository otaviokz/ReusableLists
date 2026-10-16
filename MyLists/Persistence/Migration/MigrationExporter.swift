//
//  MigrationExporter.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 15/10/2026.
//

import Foundation
import SwiftData

/// Serialises all of the user's data into a JSON file that can be imported by Reusable Lists++.
struct MigrationExporter {
    /// URL scheme registered by Reusable Lists++, used to detect whether it's installed.
    static let reusableListsPlusPlusURL = URL(string: "reusablelistsplusplus://")!
    static let reusableListsPlusPlusAppStoreURL = URL(string: "https://apps.apple.com/us/app/repeatable-checklists/id6822521966")!
    
    let context: ModelContext
    
    /// Fetches every list and blueprint, encodes them as JSON and writes the result to a temporary file.
    func exportToFile() throws -> URL {
        let lists = try context.fetch(FetchDescriptor<ToDoList>(sortBy: [SortDescriptor(\.timestamp)]))
        let blueprints = try context.fetch(FetchDescriptor<Blueprint>(sortBy: [SortDescriptor(\.name)]))
        
        let export = MigrationExport(
            formatVersion: MigrationExport.currentFormatVersion,
            exportDate: .now,
            toDoLists: lists.map(MigrationExport.ToDoList.init),
            blueprints: blueprints.map(MigrationExport.Blueprint.init)
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(export)
        
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("ReusableLists-Export.json")
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }
}

/// Plain Codable representation of the app's data, decoupled from the SwiftData schema.
struct MigrationExport: Codable {
    static let currentFormatVersion = 1
    
    let formatVersion: Int
    let exportDate: Date
    let toDoLists: [ToDoList]
    let blueprints: [Blueprint]
    
    struct ToDoList: Codable {
        let name: String
        let details: String
        let timestamp: Date
        let isNumbered: Bool
        let priority: Bool
        let items: [ToDoItem]
    }
    
    struct ToDoItem: Codable {
        let name: String
        let priority: Bool
        let done: Bool
        let number: Int
    }
    
    struct Blueprint: Codable {
        let name: String
        let details: String
        let usageCount: Int
        let isNumbered: Bool
        let items: [BlueprintItem]
    }
    
    struct BlueprintItem: Codable {
        let name: String
        let priority: Bool
        let number: Int
    }
}

private extension MigrationExport.ToDoList {
    init(_ list: DataSchemaV6.ToDoList) {
        self.init(
            name: list.name,
            details: list.details,
            timestamp: list.timestamp,
            isNumbered: list.isNumbered,
            priority: list.priority,
            items: list.items
                .sorted { $0.number < $1.number }
                .map { MigrationExport.ToDoItem(name: $0.name, priority: $0.priority, done: $0.done, number: $0.number) }
        )
    }
}

private extension MigrationExport.Blueprint {
    init(_ blueprint: DataSchemaV6.Blueprint) {
        self.init(
            name: blueprint.name,
            details: blueprint.details,
            usageCount: blueprint.usageCount,
            isNumbered: blueprint.isNumbered,
            items: blueprint.items
                .sorted { $0.number < $1.number }
                .map { MigrationExport.BlueprintItem(name: $0.name, priority: $0.priority, number: $0.number) }
        )
    }
}
