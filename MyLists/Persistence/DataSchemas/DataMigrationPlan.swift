//
//  File.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 10/11/2024.
//

import SwiftData

typealias ToDoList = DataSchemaV4.ToDoList
typealias ToDoItem = DataSchemaV4.ToDoItem
typealias Blueprint = DataSchemaV4.Blueprint
typealias BlueprintItem = DataSchemaV4.BlueprintItem

// MARK: - Migration plan
enum DataMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [DataSchemaV1.self, DataSchemaV2.self, DataSchemaV3.self, DataSchemaV4.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2, migrateV2toV3, migrateV3toV4]
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
        let list = try context.fetch(FetchDescriptor<DataSchemaV4.ToDoList>())
        list.forEach { $0.sortType = .todoFirst}
        
        try context.save()
    }
}
