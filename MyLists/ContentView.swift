//
//  ContentView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext

    var body: some View {
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

#Preview {
    ContentView()
}
