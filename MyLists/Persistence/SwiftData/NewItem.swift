//
//  NewItem.swift
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
}
