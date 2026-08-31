//
//  NewEntityCreatorProtocol.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 20/11/2024.
//

import SwiftUI

/// Creates either a ToDoList or a BluePrint
@MainActor
protocol NewEntityCreatorProtocol {
    func createNewEntity(name: String, details: String, priority: Bool)
    func insertEntity(name: String, details: String, priority: Bool) throws
    func handleSaveError(error: Error, name: String)
}

extension NewEntityCreatorProtocol {
    func createNewEntity(name: String, details: String, priority: Bool) {
        Task {
            do {
                try await Task.sleep(nanoseconds: WaitTimes.dismissSheetAndInsertOrRemove)
                
                try withAnimation(.easeIn(duration: 0.25)) {
                    try insertEntity(name: name, details: details, priority: priority)
                }
                
            } catch {
                handleSaveError(error: error, name: name)
            }
        }
    }
}
