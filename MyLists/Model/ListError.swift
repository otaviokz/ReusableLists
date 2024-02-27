//
//  ListError.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import Foundation

enum ListError: Error {
    case listNameUnavailable(_ name: String)
    case unableToCreateInstance
    case unknown(_ error: Error)
    
    var message: String {
        switch self {
            case .listNameUnavailable(let name): return "A ToDoList called \(name) already exists."
            case .unableToCreateInstance: return "Unable to create ToDoList, try again later."
            case .unknown(let error): return "Unable to perform task, try again later. [\(error.localizedDescription)]"
        }
    }
}
