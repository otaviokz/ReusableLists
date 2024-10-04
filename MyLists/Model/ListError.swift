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
    case blueprintExistsForList(named: String)
    case emptyDeleteIndexSet
    case unknown(error: Error?)

    var message: String {
        return switch self {
            case .listNameUnavailable(let name): "A List called \"\(name)\" already exists."
            case .listExistsForBlueprint(let name): "A List already exists for \"\(name)\"."
            case .blueprintNameUnavailable(let name): "A Blueprint called \"\(name)\" already exists."
            case .blueprintExistsForList(let name): "A Blueprint already exists for \"\(name)\"."
            case .unknown: Alert.gnericErrorMessage
            default: Alert.gnericErrorMessage
        }
    }
}
