//
//  ListError.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import Foundation
import SwiftUI

enum ListError: Error {
    case listNameUnavailable(name: String)
    case listExistsForBlueprint(named: String)
    case blueprintNameUnavailable(name: String)
    case blueprintExistsForList(named: String)
    case deleteEntityIndexNotFound
    case unknown(error: Error?)

    var message: String {
        return switch self {
            case .listNameUnavailable(let name): "A ToDoList called \(name) already exists."
            case .listExistsForBlueprint(let name): "A ToDoList already exists for \"\(name)\" Blueprint."
            case .blueprintNameUnavailable(let name): "A blueprint called \(name) already exists."
            case .blueprintExistsForList(let name): "A blueprint already exists for \"\(name)\" ToDoList."
            case .unknown(_): Alert.defaultErrorMessage
            default: Alert.defaultErrorMessage
        }
    }
}
