//
//  Priority.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import Foundation
import SwiftUI

enum Priority: Int, Codable {
    case low = 0
    case medium = 1
    case high = 2
    
    init(rawValue: Int) {
        switch rawValue {
            case 0: self = .low
            case 1: self = .medium
            default: self = .high
        }
    }
    
    var color: Color {
        switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .red
        }
    }
}
