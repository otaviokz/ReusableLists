//
//  BlueprintItemRowView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 26/02/2024.
//

import Foundation
import SwiftUI

struct BlueprintItemRowView: View {
    @State private var showAlert = false
    let item: BlueprintItem
    
    var body: some View {
        HStack {
            Text(item.name)
                .font(.headline.weight(.medium))
            Spacer()
        }
        .onLongPressGesture {
            UIPasteboard.general.string = item.name
            showAlert = true
        }
        .alert("'\(item.name)' copied to Pasteboard", isPresented: $showAlert) {
            Button("OK", role: .cancel) { showAlert = false }
        }
    }
}

#Preview {
    VStack {
        BlueprintItemRowView(item: BlueprintItem(name: "Banana"))
    }
}
