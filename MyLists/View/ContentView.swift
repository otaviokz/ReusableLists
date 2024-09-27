//
//  ContentView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

class TabSelection: ObservableObject {
    @Published var selectedTab: Int {
        willSet {
            lastSelectedTab = selectedTab
        }
    }
    @Published private(set)var lastSelectedTab: Int
    
    init(selectedTab: Int) {
        self.selectedTab = selectedTab
        self.lastSelectedTab = selectedTab
    }
}

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject var tabSelection = TabSelection(selectedTab: 1)

    var body: some View {
        TabView(selection: $tabSelection.selectedTab) {
            NavigationView {
                ToDoListsView()
            }
            .tabItem {
                Label("Check lists", systemImage: "list.bullet.clipboard")
            }
            .tag(1)
            
            NavigationView {
                BlueprintsListView()
            }
            .tabItem {
                Label("Blueprints", systemImage: "pencil.and.list.clipboard")
                    .symbolRenderingMode(.hierarchical)
            }
            .tag(2)
            
            NavigationView {
                AboutView()
            }
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
            .tag(3)
        }
        .modelContext(modelContext)
        .modelContainer(for: [ToDoList.self, Blueprint.self, ToDoItem.self, BlueprintItem.self], isUndoEnabled: true)
        .onAppear {
            tabSelection.selectedTab = 1
        }
        .environmentObject(tabSelection)
        

    }
}

#Preview {
    ContentView()
}

extension Binding<Int>: @retroactive Equatable {
    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}
