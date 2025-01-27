//
//  DataSchemaV4.swift
//  ReusableLists
//
//  Created by okz on 27/01/25.
//

import Foundation
import SwiftData

struct DataSchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 1, 0)
    
    static var models: [any PersistentModel.Type] {
        [ToDoList.self, ToDoItem.self, Blueprint.self, BlueprintItem.self]
    }
}

extension DataSchemaV4 {
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
        var priority = false
        var done: Bool = false
        
        init(_ name: String = "", priority: Bool = false, done: Bool = false) {
            self.name = name
            self.priority = priority
            self.done = done
        }
    }
    
    @Model
    final class Blueprint: ObservableObject {
        var name: String
        var details: String
        var usageCount: Int = 0
        
        @Relationship(deleteRule: .cascade) var items: [BlueprintItem] = []
        
        init(_ name: String, details: String = "") {
            self.name = name.asInput
            self.details = details.asInput
        }
    }
    
    @Model
    final class BlueprintItem: ObservableObject {
        var name: String
        var priority: Bool = false
        
        init(_ name: String, priority: Bool = false) {
            self.name = name
            self.priority = priority
        }
        
        func asToDoItem() -> ToDoItem {
            ToDoItem(name, priority: priority)
        }
    }
}
