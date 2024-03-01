//
//  Reusable_Lists_ClipApp.swift
//  Reusable Lists Clip
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import SwiftUI
import SwiftData

@main
struct Reusable_Lists_ClipApp: App {
    @Environment(\.modelContext) var modelContext
    
    var body: some Scene {
        TabView {
            NavigationView {
                ToDoListsView()
                    .onAppear {
                        if modelContext.undoManager == nil {
                            modelContext.undoManager = UndoManager()
                        }
                    }
            }
            .tabItem {
                Label("Lists", systemImage: "list.bullet.clipboard")
            }
            NavigationView {
                BlueprintsListView()
                    .onAppear {
                        if modelContext.undoManager == nil {
                            modelContext.undoManager = UndoManager()
                        }
                    }
            }
            .tabItem {
                Label("Blueprints", systemImage: "archivebox")
            }
        }
    }
}
