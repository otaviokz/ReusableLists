//
//  MyListsApp.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

@main
struct MyListsApp: App {
    @Environment(\.modelContext) var modelContext
    
    var body: some Scene {

        WindowGroup {
            ContentView()
                .environment(\.modelContext, modelContext)
                .modelContainer(for: [ToDoList.self, Blueprint.self, ToDoItem.self, BlueprintItem.self], isUndoEnabled: true)
        }
        
    }
}
