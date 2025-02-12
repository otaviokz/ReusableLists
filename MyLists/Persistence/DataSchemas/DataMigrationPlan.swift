//
//  File.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 10/11/2024.
//

import SwiftData

// MARK: - Migration plan
enum DataMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [DataSchemaV1.self, DataSchemaV2.self, DataSchemaV3.self,
         DataSchemaV4.self, DataSchemaV5.self, DataSchemaV6.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2, migrateV2toV3, migrateV3toV4, migrateV4toV5, migrateV5toV6]
    }
    
    static let migrateV1toV2: MigrationStage = .lightweight(
        fromVersion: DataSchemaV1.self,
        toVersion: DataSchemaV2.self
    )
    
    static let migrateV2toV3: MigrationStage = .custom(
        fromVersion: DataSchemaV2.self,
        toVersion: DataSchemaV3.self,
        willMigrate: nil
    ) { context in
        let blueprints = try context.fetch(FetchDescriptor<DataSchemaV3.Blueprint>())
        blueprints.forEach { $0.usageCount = 0 }
        try context.save()
    }
    
    static let migrateV3toV4: MigrationStage = .custom(
        fromVersion: DataSchemaV3.self,
        toVersion: DataSchemaV4.self,
        willMigrate: nil
    ) { context in
        let todoItems = try context.fetch(FetchDescriptor<DataSchemaV4.ToDoItem>())
        todoItems.forEach { $0.priority = false }
        let bluepritItems = try context.fetch(FetchDescriptor<DataSchemaV4.BlueprintItem>())
        bluepritItems.forEach { $0.priority = false }
        try context.save()
    }
    
    static let migrateV4toV5: MigrationStage = .custom(
        fromVersion: DataSchemaV4.self,
        toVersion: DataSchemaV5.self,
        willMigrate: nil
    ) { context in
        let toDoLists = try context.fetch(FetchDescriptor<DataSchemaV5.ToDoList>())
        toDoLists.forEach { $0.isNumbered = false }
        let todoItems = try context.fetch(FetchDescriptor<DataSchemaV5.ToDoItem>())
        todoItems.forEach { $0.number = 0 }
        let blueprints = try context.fetch(FetchDescriptor<DataSchemaV5.Blueprint>())
        blueprints.forEach { $0.isNumbered = false }
        let blueprintItems = try context.fetch(FetchDescriptor<DataSchemaV5.BlueprintItem>())
        blueprintItems.forEach { $0.number = 0 }
    }
    
    static let migrateV5toV6: MigrationStage = .custom(
        fromVersion: DataSchemaV5.self,
        toVersion: DataSchemaV6.self,
        willMigrate: nil
    ) { context in
        let toDoLists = try context.fetch(FetchDescriptor<DataSchemaV6.ToDoList>())
        toDoLists.forEach { $0.priority = false }
    }
}
