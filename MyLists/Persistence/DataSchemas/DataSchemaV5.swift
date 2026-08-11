//
//  DataSchemaV5.swift
//  ReusableLists
//
//  Created by okz on 01/02/25.
//

import Foundation
import SwiftData

struct DataSchemaV5: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 3, 0)
    
    static var models: [any PersistentModel.Type] {
        [ToDoList.self, ToDoItem.self, Blueprint.self, BlueprintItem.self]
    }
}

extension DataSchemaV5 {
    @Model
    final class ToDoList: ObservableObject {
        var name: String
        var details: String
        @Attribute(originalName: "creationDate")
        var timestamp: Date
        @Relationship(deleteRule: .cascade) var items: [ToDoItem] = []
        var isNumbered: Bool = false
        
        init(_ name: String = "", details: String = "", isNumbered: Bool = false) {
            self.name = name
            self.timestamp = .now
            self.details = details
            self.isNumbered = isNumbered
        }
    }
    
    @Model
    final class ToDoItem: ObservableObject {
        var name: String
        var priority = false
        var done: Bool = false
        var number: Int = 0
        
        init(_ name: String = "", priority: Bool = false, done: Bool = false, number: Int = 0) {
            self.name = name
            self.priority = priority
            self.done = done
            self.number = number
        }
    }
    
    @Model
    final class Blueprint: ObservableObject {
        var name: String
        var details: String
        var usageCount: Int = 0
        var isNumbered: Bool = false
        @Relationship(deleteRule: .cascade) var items: [BlueprintItem] = []
        
        init(_ name: String, details: String = "", isNumbered: Bool = false) {
            self.name = name.asInput
            self.details = details.asInput
            self.isNumbered = isNumbered
        }
    }
    
    @Model
    final class BlueprintItem: ObservableObject {
        var name: String
        var priority: Bool = false
        var number = 0
        
        init(_ name: String, priority: Bool = false, number: Int = 0) {
            self.name = name
            self.priority = priority
            self.number = number
        }
        
        func asToDoItem() -> ToDoItem {
            ToDoItem(name, priority: priority)
        }
    }
}
