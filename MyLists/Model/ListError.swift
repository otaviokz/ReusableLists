//
//  ListError.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import Foundation
import SwiftUI

enum ListError: Error {
    case listNameUnavailable(_ name: String)
    case blueprintNameUnavailable(_ name: String)
    case unableToCreateInstance(error: Error)
    case bluePrintItemNotFound
    case unknown(_ error: Error)

    var message: String {
        return switch self {
            case .listNameUnavailable(let name): "A ToDoList called \(name) already exists."
            case .blueprintNameUnavailable(let name): "A Blueprint called \(name) already exists."
            case .unableToCreateInstance(let error), .unknown(let error): "Unable to perform task, try again later. [\(error.localizedDescription)]"
            case .bluePrintItemNotFound:
                Alert.defaultErrorMessage
        }
    }
}
