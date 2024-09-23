//
//  Styling.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 23/09/2024.
//

import SwiftUI

struct Images {
    static let checkBoxTicked = Image(systemName: "checkmark.square")
    static let checkBox = Image(systemName: "square")
    static let plus = Image(systemName: "plus")
    static let checkMark = Image(systemName: "checkmark")
    static let docOnDoc = Image(systemName: "doc.on.doc")
    static let gear = Image(systemName: "gear")
    static let sort = Image(systemName: "arrow.up.arrow.down")
}

struct Formatters {
    static var noDecimals: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }
}
