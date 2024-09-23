//
//  NoDecimalsNumberFormattable.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 22/09/2024.
//

import SwiftUI

protocol NoDecimalsNumberFormattable: View {
    static var noDecimalsFormatter: NumberFormatter { get }
}

extension NoDecimalsNumberFormattable {
    static var noDecimalsFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
//        formatter.percentSymbol = "﹪"
        return formatter
    }
}
