//
//  ListEntity.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 08/10/2024.
//

import SwiftUI

enum ListEntity: String {
    case toDoList = "List"
    case blueprint = "Blueprint"
    
    var formDetailsFieldPrompt: String {
        "Optional field. You can use it to register relevant details about your \(rawValue)."
    }
    
    var headerImage: Image {
        switch self {
            case .toDoList: Image.todolist
            case .blueprint: Image.blueprint
        }
    }
    
    var addEntityTitleImageRightPadding: CGFloat {
        switch self {
            case .toDoList: 4
            case .blueprint: 0
        }
    }
}
