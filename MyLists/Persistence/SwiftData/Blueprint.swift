//
//  MetaList.swift
//  ReusableLists
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
    
    init(_ name: String, details: String = "") {
        self.name = name.asInput
        self.details = details.asInput
    }
}

extension Blueprint {
    static var placeholderBlueprint: Blueprint {
        Blueprint("Placeholder")
    }
}
