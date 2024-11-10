//
//  ReusableListsApp.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

typealias ToDoList = DataSchemaV1.ToDoList
typealias ToDoItem = DataSchemaV1.ToDoItem
typealias Blueprint = DataSchemaV1.Blueprint
typealias BlueprintItem = DataSchemaV1.BlueprintItem

@main
struct ReusableListsApp: App {
    @Environment(\.modelContext) var modelContext

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.modelContext, modelContext)
                .modelContainer(
                    for: [ToDoList.self, Blueprint.self, ToDoItem.self, BlueprintItem.self],
                    isUndoEnabled: true
                )
        }
    }
    
    func buildModelContainer() -> ModelContainer {
        let schema = Schema([ToDoList.self, ToDoItem.self, Blueprint.self, BlueprintItem.self])
        let configuration = ModelConfiguration()
        do {
            let container = try ModelContainer(
                for: schema,
                migrationPlan: nil,
                configurations: [configuration]
            )
            return container
        } catch {
            fatalError()
        }
        
    }
}
