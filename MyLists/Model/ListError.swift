//
//  ListError.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import Foundation
import SwiftUI

enum ListError: Error {
    case listNameUnavailable(name: String)
    case listExistsForBlueprint(named: String)
    case blueprintNameUnavailable(name: String)
    case emptyDeleteIndexSet

    var message: String {
        return switch self {
            case .listNameUnavailable(let name): "A List called \"\(name)\" already exists."
            case .listExistsForBlueprint(let name): "A List already exists for \"\(name)\"."
            case .blueprintNameUnavailable(let name): "A Blueprint called \"\(name)\" already exists."
            default: Alert.genericErrorMessage
        }
    }
}
