//
//  String+Trimming.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import Foundation

extension String {
    var trimmingSpaces: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func trimmingSpacesLowercasedEquals(_ rhs: String) -> Bool {
        trimmingSpaces.lowercased() == rhs.trimmingSpaces.lowercased()
    }
}
