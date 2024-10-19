//
//  NewItemForEntity.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 18/10/2024.
//

import SwiftUI

enum NewItemForEntity {
    case toDoList(entity: ToDoList)
    case blueprint(entity: Blueprint)
    
    var image: Image {
        switch self {
            case.toDoList: Image.todolist
            case.blueprint: Image.blueprint
        }
    }
    
//    var listModel: ToDoList? {
//        switch self {
//            case .toDoList(let list): list
//            default: nil
//        }
//    }
//    
//    var blueprintModel: Blueprint? {
//        switch self {
//            case .blueprint(
//                let blueprint): blueprint
//            default: nil
//        }
//    }
}
