//
//  ReusableListsApp.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

// MARK: - Model

@main
struct ReusableListsApp: App {
    @Environment(\.modelContext) var modelContext

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.modelContext, modelContext)
                .modelContainer(buildModelContainer())
        }
    }
    
    func buildModelContainer() -> ModelContainer {
        let schema = Schema([ToDoList.self, ToDoItem.self, Blueprint.self, BlueprintItem.self])
        let configuration = ModelConfiguration()
        do { 
            let container = try ModelContainer(
                for: schema,
                migrationPlan: DataMigrationPlan.self,
                configurations: [configuration]
            )
            return container
        } catch {
            fatalError()
        }
    }
}
