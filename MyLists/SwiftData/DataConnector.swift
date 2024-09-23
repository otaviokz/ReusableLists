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
    @Environment(\.modelContext) private var modelContext: ModelContext
    
    let lists: [ToDoList]
    
    init(lists: [ToDoList]) {
        self.lists = lists
    }
    
    func createInstance(of blueprint: Blueprint) throws {
        if instanceExistsFor(blueprint) {
            throw ListError.listNameUnavailable(blueprint.name)
        }
        
        let list = ToDoList(name: blueprint.name, details: blueprint.details)
        for item in blueprint.items.asToDoItemList() {
            modelContext.insert(item)
        }
        list.items = blueprint.items.asToDoItemList()
        modelContext.insert(list)
        
        try modelContext.save()
    }
    
    func instanceExistsFor(_ blueprint: Blueprint) -> Bool {
        !lists.filter { $0.name.trimmingSpacesLowercasedEquals(blueprint.name) }.isEmpty
    }
}
