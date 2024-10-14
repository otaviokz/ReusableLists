//
//  TestDataController.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 10/10/2024.
//

import SwiftData
@testable import ReusableLists

@MainActor
class TestDataController {
    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: ToDoList.self, ToDoItem.self, Blueprint.self, BlueprintItem.self, configurations: config)
            
            container.deleteAllData()
            
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}
