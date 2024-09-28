//
//  RoundedFormViewModifier.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 22/09/2024.
//

import SwiftUI

struct RoundClipped: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    func roundClipped() -> some View {
        modifier(RoundClipped())
    }
}
