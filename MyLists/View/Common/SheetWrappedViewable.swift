//
//  SheetWrappedPresentable.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 23/09/2024.
//

import SwiftUI

protocol SheetWrappedViewable: View {
    var isSheetPresented: Binding<Bool> { get }
    func dismissSheet()
}

extension SheetWrappedViewable {
    func dismissSheet() {
        isSheetPresented.wrappedValue = false
    }
}
