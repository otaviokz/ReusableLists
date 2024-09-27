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
    case blueprintNameUnavailable(name: String)
    case listExistsForBlueprinte(named: String)
    case unknown(error: Error?)

    var message: String {
        return switch self {
            case .listNameUnavailable(let name): "A ToDoList called \(name) already exists."
            case .listExistsForBlueprinte(let name): "A list already exists for \"\(name)\" Blueprint"
            case .unknown(_): Alert.defaultErrorMessage
            default: Alert.defaultErrorMessage
        }
    }
}
