//
//  NewEntityItem.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 22/10/2024.
//

import SwiftUI

enum NewEntityItem {
    case toDoList(entity: ToDoList)
    case blueprint(entity: Blueprint)
    
    var image: Image {
        switch self {
            case.toDoList: Image.todolist
            case.blueprint: Image.blueprint
        }
    }
    
    var name: String {
        switch self {
            case .toDoList(let list): "List: \"\(list.name)\""
            case .blueprint(let blueprint): "Blueprint: \"\(blueprint.name)\""
        }
    }
    
    var nameNotAvailableMessage: String {
        switch self {
            case .toDoList: "⚠ An item named \"\(name)\" already exists for this List."
            case .blueprint: "⚠ An item named \"\(name)\" already exists for this Blueprint."
        }
    }
}
