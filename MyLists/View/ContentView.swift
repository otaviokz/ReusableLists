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
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var tabSelection = TabSelection()
    @State private var onboardingCompleted = true
    @State private var onboardingState: OnboardingState
    @State private var showFinalVersionNotice = false
    private let finalVersionUpdate = FinalVersionUpdate()
    
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
                            .modelContainer(DataManager.sharedInstance.modelContainer)
                    }
                    .tabItem {
                        Label("About", systemImage: "info.circle")
                    }
                    .tag(3)
                }
                .accentColor(colorScheme == .dark ? .cyan : .blue)
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
            if finalVersionUpdate.isFirstLaunchAfterUpdate {
                if finalVersionUpdate.isUpdatingFromOlderVersion {
                    showFinalVersionNotice = true
                } else {
                    // Fresh install: never show the notice, even after onboarding is completed.
                    finalVersionUpdate.markAsSeen()
                }
            }
        }
        .alert(isPresented: $showFinalVersionNotice) {
            Alert(
                title: Text(FinalVersionUpdate.noticeTitle),
                message: Text(FinalVersionUpdate.noticeMessage),
                dismissButton: .default(Text("OK")) {
                    finalVersionUpdate.markAsSeen()
                }
            )
        }
        .environmentObject(onboardingState)
    }
}

#Preview {
    @Previewable @State var onboardingFinished: Bool = false
    ContentView()
}
