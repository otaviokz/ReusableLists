//
//  DataManager.swift
//  ReusableLists
//
//  Created by okz on 10/02/25.
//

import SwiftData
import Foundation
import UIKit
import Combine

typealias ToDoList = DataSchemaV6.ToDoList
typealias ToDoItem = DataSchemaV6.ToDoItem
typealias Blueprint = DataSchemaV6.Blueprint
typealias BlueprintItem = DataSchemaV6.BlueprintItem

@MainActor
class DataManager {
    
    static var sharedInstance = DataManager()

    var modelContainer: ModelContainer
    var viewContext: ModelContext
    
    init() {
        do {
            self.modelContainer = try ModelContainer(
                for: Schema([ToDoList.self, ToDoItem.self, Blueprint.self, BlueprintItem.self]),
                migrationPlan: DataMigrationPlan.self,
                configurations: [ModelConfiguration()]
            )
            self.viewContext = modelContainer.mainContext
        } catch {
            fatalError()
        }
    }
}
