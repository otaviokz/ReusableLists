//
//  RoundBackgroundAndBorderModifier.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 11/10/2024.
//

import SwiftUI

struct RoundBorderedModifier: ViewModifier {
    let borderColor: Color
    let boderWidht: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: boderWidht)
                    )
            }
    }
}

extension View {
    func roundBordered(borderColor: Color, boderWidht: CGFloat = 1) -> some View {
        modifier(RoundBorderedModifier(borderColor: borderColor, boderWidht: boderWidht))
    }
}
