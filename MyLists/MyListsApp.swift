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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ToDoList.self, isUndoEnabled: true)
    }
}
