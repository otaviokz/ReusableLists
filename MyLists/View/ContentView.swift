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
//    @State private var tabSelection = 1
    
    var body: some View {
        TabView/*(selection: $tabSelection)*/ {
            NavigationView {
                ToDoListsView()
            }
            .tabItem {
                Label("Lists", systemImage: "list.bullet.clipboard")
            }
//            .tag(1)
            
            NavigationView {
                BlueprintsListView()
            }
            .tabItem {
                Label("Blueprints", systemImage: "archivebox")
            }
//            .tag(2)
            
            NavigationView {
                AboutView()
            }
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
//            .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
