//
//  Styling.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 23/09/2024.
//

import SwiftUI

extension Image {
    static let checkBoxTicked = Image(systemName: "checkmark.square")
    static let checkBox = Image(systemName: "square")
    static let plus = Image(systemName: "plus")
    static let checkMark = Image(systemName: "checkmark")
    static let docOnDoc = Image(systemName: "doc.on.doc")
    static let gear = Image(systemName: "gear")
    static let sort = Image(systemName: "arrow.up.arrow.down")
    static let play = Image(systemName: "play.circle")
    static let share = Image(systemName: "square.and.arrow.up")
    static let trash = Image(systemName: "trash")
    static func imageForItem(_ item: ToDoItem) -> Image {
        item.done ? checkBoxTicked : checkBox
    }
}

extension NumberFormatter {
    static var noDecimals: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }
}

struct SizeConstraints {
    static var name: Int { 64 }
    static var details: Int { 128 }
}

