//
//  MetaList.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 26/02/2024.
//

import Foundation
import SwiftData

@Model
final class Blueprint: ObservableObject {
    var name: String
    var details: String
    @Relationship(deleteRule: .cascade) var items: [BlueprintItem] = []
//    @Relationship(deleteRule: .nullify) weak var list: ToDoList?
    
    init(name: String, details: String = "") {
        self.name = name.trimmingSpaces
        self.details = details.trimmingSpaces
    }
}
