//
//  String+Trimming.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import Foundation

extension String {
    var trimmingSpaces: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var asInput: String {
        trimmingSpaces
    }
    
    func trimLowcaseEquals(_ rhs: String) -> Bool {
        asInput.lowercased() == rhs.asInput.lowercased()
    }
    
    var isEmptyAsInput: Bool {
        asInput.isEmpty
    }
}
