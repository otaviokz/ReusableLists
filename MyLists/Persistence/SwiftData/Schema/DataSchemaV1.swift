//
//  ReusableListsSchemaV1.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 09/11/2024.
//

import SwiftUI
import SwiftData

struct DataSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [ToDoList.self, ToDoItem.self, Blueprint.self, BlueprintItem.self]
    }
}

extension DataSchemaV1 {
    @Model
    final class ToDoList: ObservableObject {
        var name: String
        var details: String
        var creationDate: Date
        
        @Relationship(deleteRule: .cascade) var items: [ToDoItem] = []
        
        init(_ name: String = "", details: String = "") {
            self.name = name
            self.creationDate = .now
            self.details = details
        }
        
        //        @Attribute(.externalStorage) var image: Data?
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
