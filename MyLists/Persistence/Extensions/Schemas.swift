//
//  Schemas.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 23/09/2024.
//

import SwiftData
import SwiftUI

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        return [ToDoList.self, ToDoItem.self, Blueprint.self, BlueprintItem.self]
    }
}

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    
    @Model
    final class TodoItem: ObservableObject {
        var name: String
        var done: Bool
        
        init(name: String = "", done: Bool = false) {
            self.name = name
            self.done = done
        }
    }
    
    @Model
    final class BlueprintItem {
        var name: String
        init(name: String) {
            self.name = name
        }
        
        func asToDoItem() -> ToDoItem {
            ToDoItem(name: name, done: false)
        }
    }
    
    @Model
    class Blueprint: ObservableObject {
        var name: String
        var details: String
        
        @Relationship(deleteRule: .cascade) var items: [BlueprintItem] = []
        @Relationship(deleteRule: .nullify) var list: ToDoList?
        
        init(name: String, details: String = "") {
            self.name = name.trimmingSpaces
            self.details = details.trimmingSpaces
        }
    }
    
    static var models: [any PersistentModel.Type] {
        return [ToDoList.self, ToDoItem.self, Blueprint.self, BlueprintItem.self]
    }
}


