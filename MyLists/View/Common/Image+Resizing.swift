//
//  Image+Resizing.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 23/09/2024.
//

import SwiftUI

extension Image {
    func sizedToFit(width: CGFloat = 20, height: CGFloat = 20, alignment: Alignment = .center) -> some View {
        resizable().frame(width: width, height: height, alignment: alignment).scaledToFit()
    }
}
