//
//  ContentView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var tabSelection = TabSelection()
    @State private var onboardingCompleted = true
    @State private var onboardingState: OnboardingState
    
    init() {
        onboardingState = OnboardingState()
    }
    
    var body: some View {
        VStack {
            if onboardingCompleted {
                TabView(selection: $tabSelection.selectedTab) {
                    NavigationStack {
                        ToDoListsView()
                    }
                    .tabItem {
                        Label("Lists", systemImage: "list.bullet.clipboard")
                    }
                    .tag(1)
                    
                    NavigationStack {
                        BlueprintsView()
                    }
                    .tabItem {
                        Label("Blueprints", systemImage: "pencil.and.list.clipboard")
                    }
                    .tag(2)
                    
                    NavigationStack {
                        AboutView()
                    }
                    .tabItem {
                        Label("About", systemImage: "info.circle")
                    }
                    .tag(3)
                }
                .accentColor(.cyan)
                .modelContainer(
                    for: [ToDoList.self, Blueprint.self, ToDoItem.self, BlueprintItem.self],
                    isUndoEnabled: true
                )
                .onAppear {
                    tabSelection.select(tab: 1)
                }
                .environmentObject(tabSelection)
                
            } else {
                OboardingPagedView()                    
            }
        }
        .task {
            onboardingState.completed = $onboardingCompleted
        }
        .environmentObject(onboardingState)
    }
}

#Preview {
    @Previewable @State var onboardingFinished: Bool = false
    ContentView()
}

extension Binding<Int>: @retroactive Equatable {
    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}
