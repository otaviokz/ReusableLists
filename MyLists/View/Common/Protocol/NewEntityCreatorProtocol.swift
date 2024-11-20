//
//  NewEntityCreatorProtocol.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 20/11/2024.
//

import SwiftUI

/// Creates either a ToDoList or a BluePrint
protocol NewEntityCreatorProtocol {
    func createNewEntity(name: String, details: String)
    func isUniqueName(name: String) -> Bool
    func insertEntity(name: String, details: String) throws
    func handleSaveError(error: Error, name: String)
}

extension NewEntityCreatorProtocol {
    func createNewEntity(name: String, details: String) {
        Task {
            do {
                try await Task.sleep(nanoseconds: WaitTimes.sheetDismissAndInsertOrRemove)
                
                try withAnimation(.easeIn(duration: 0.25)) {
                    try insertEntity(name: name, details: details)
                }
                
            } catch {
                handleSaveError(error: error, name: name)
            }
        }
    }
}
