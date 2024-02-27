//
//  DataConnector.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import Foundation
import SwiftUI
import SwiftData

class DataConnector {
    private var modelContext: ModelContext
    let lists: [ToDoList]
    
    init(lists: [ToDoList], modelContext: ModelContext) {
        self.lists = lists
        self.modelContext = modelContext
    }
    
    func createInstance(of blueprint: Blueprint) throws {
        if instanceExistsFor(blueprint) {
            throw ListError.listNameUnavailable(blueprint.name)
        }
        
        let list = ToDoList(name: blueprint.name, details: blueprint.details)
        list.items = blueprint.items.asToDoItemArray()
        modelContext.insert(list)
    }
    
    func instanceExistsFor(_ blueprint: Blueprint) -> Bool {
        !lists.filter { $0.name.trimmingSpacesLowercasedEquals(blueprint.name) }.isEmpty
    }
}
