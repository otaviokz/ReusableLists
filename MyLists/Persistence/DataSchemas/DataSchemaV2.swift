//
//  ReusableListsSchemaV2.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 10/11/2024.
//

import Foundation
import SwiftData

struct DataSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 1)
    
    static var models: [any PersistentModel.Type] {
        [ToDoList.self, ToDoItem.self, Blueprint.self, BlueprintItem.self]
    }
}

extension DataSchemaV2 {
    @Model
    final class ToDoList: ObservableObject {
        var name: String
        var details: String
        @Attribute(originalName: "creationDate")
        var timestamp: Date
        
        @Relationship(deleteRule: .cascade) var items: [ToDoItem] = []
        
        init(_ name: String = "", details: String = "") {
            self.name = name
            self.timestamp = .now
            self.details = details
        }        
    }
    
    @Model
    final class ToDoItem: ObservableObject {
        var name: String
        var done: Bool = false
        
        init(_ name: String = "", done: Bool = false) {
            self.name = name
            self.done = done
        }
    }
    
    @Model
    final class Blueprint: ObservableObject {
        var name: String
        var details: String
        @Relationship(deleteRule: .cascade) var items: [BlueprintItem] = []
        
        init(_ name: String, details: String = "") {
            self.name = name.asInput
            self.details = details.asInput
        }
    }
    
    @Model
    final class BlueprintItem: ObservableObject {
        var name: String
        
        init(_ name: String) {
            self.name = name
        }
        
        func asToDoItem() -> ToDoItem {
            ToDoItem(name)
        }
    }
}
