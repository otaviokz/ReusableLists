//
//  Styling.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 23/09/2024.
//

import SwiftUI
import UIKit

extension Image {
    static let checkBoxTicked = Image(systemName: "checkmark.square")
    static let checkBox = Image(systemName: "square")
    // swiftlint:disable:next identifier_name
    static let az = Image("a-z")
    static let plus = Image(systemName: "plus")
    static let checkMark = Image(systemName: "checkmark")
    static let docOnDoc = Image(systemName: "doc.on.doc")
    static let gear = Image(systemName: "gear")
    static let sort = Image(systemName: "arrow.up.arrow.down")
    static let play = Image(systemName: "play.circle")
    static let share = Image(systemName: "square.and.arrow.up")
    static let trash = Image(systemName: "trash")
    public static var todolist: Image { Image(systemName: "list.bullet.clipboard") }
    public static var blueprint: Image { Image(systemName: "pencil.and.list.clipboard") }
    static let backward = Image(systemName: "backward")
    static let forward = Image(systemName: "forward")
    static let iconSize: CGFloat = 20
    static func checkBoxImageForItem(_ item: ToDoItem) -> Image {
        item.done ? checkBoxTicked : checkBox
    }
    static let priority = Image(systemName: "exclamationmark.circle")
}

extension NumberFormatter {
    static var noDecimals: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    static var oneDecimal: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }
}

struct SizeConstraints {
    static var detailsFieldLineLimit: Int { 2 }
}

struct Sizes {
    static var newItemFormHeight: CGFloat { 112 }
    static var newEntityFormHeight: CGFloat { 186 }
    static var exitOrSaveBottomPadding: CGFloat { 8 }
    static var updateEtityViewTopPadding: CGFloat { 8 }
}

extension TimeInterval {
    struct Animations {
        static var itemLongpress: TimeInterval { 0.175 }
        static var toggleDone: TimeInterval { 0.175 }
    }
}

extension CGSize {
    init(size: CGFloat) {
        self.init(width: size, height: size)
    }
    
    struct ScaleEffect {
        static var copyToClipboard: CGSize { CGSize(size: 1.5) }
        static var original: CGSize { CGSize(size: 1) }
    }
}
