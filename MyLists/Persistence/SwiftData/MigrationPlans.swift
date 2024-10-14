//
//  Migrations.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 23/09/2024.
//

import SwiftData

enum MigrationPlan: SchemaMigrationPlan {
    static var stages:[MigrationStage] = [MigrationPlan.migrateV1toV2]
    
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }
    
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self
    )
}





