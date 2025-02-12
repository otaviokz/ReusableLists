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
    private var modelContainer = DataManager.sharedInstance.modelContainer
    private var modelContext = DataManager.sharedInstance.viewContext

    var body: some Scene {
        WindowGroup {
            ContentView()                
                .environment(\.modelContext, modelContext)
        }
    }
}
