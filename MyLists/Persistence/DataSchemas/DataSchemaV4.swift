//
//  DataSchemaV4.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 02/12/2024.
//

import Foundation
import SwiftData

struct DataSchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 2, 0)
    
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
        var sortType: SortType
        
        @Relationship(deleteRule: .cascade) var items: [ToDoItem] = []
        
        init(_ name: String = "", details: String = "", sortType: SortType = .todoFirst) {
            self.name = name
            self.timestamp = .now
            self.details = details
            self.sortType = sortType
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
        
        init(_ name: String) {
            self.name = name
        }
        
        func asToDoItem() -> ToDoItem {
            ToDoItem(name)
        }
    }
}
