//
//  Image+Resizing.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 23/09/2024.
//

import SwiftUI

extension Image {
    func sizedToFit(
        width: CGFloat = Image.iconSize,
        height: CGFloat = Image.iconSize,
        alignment: Alignment = .center
    ) -> some View {
        resizable().frame(width: width, height: height, alignment: alignment).scaledToFit()
    }
    
    func sizedToFitHeight(_ height: CGFloat) -> some View {
        resizable().scaledToFit().frame(height: height)
    }
    
    func sizedToFitSquare(side: CGFloat = Image.iconSize, alignment: Alignment = .center) -> some View {
        sizedToFit(width: side, height: side, alignment: alignment)
    }
}
