//
//  BlueprintItemRowView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 26/02/2024.
//

import SwiftUI

struct BlueprintItemRowView: View {
    @State private var presentAlert = false
    @State private var scaleEffectSize = CGSize.ScaleEffect.original
    @State private var nameColor = Color.primary
    
    let item: BlueprintItem
    
    var body: some View {
        HStack {
            Text(item.name)
                .scaleEffect(scaleEffectSize)
                .font(.title3.weight(.light))
                .foregroundStyle(nameColor)
            
            Spacer()
        }
        // It needs to specify content shape to cover all area, since by default only opaque views handle gesture
        // https://stackoverflow.com/a/62640126/884744
        .contentShape(Rectangle())
        .onLongPressGesture {
            copyNameToClipboard()
        }
        .alert("'\(item.name)' copied to Pasteboard", isPresented: $presentAlert) {
            Button("OK", role: .cancel) { presentAlert = false }
        }
    }
}

// MARK: - UI

private extension BlueprintItemRowView {
    func copyNameToClipboard() {
        withAnimation(.linear(duration: .Animations.itemLongpress)) {
            scaleEffectSize = .ScaleEffect.copyToClipboard
            nameColor = .cyan
        } completion: {
            withAnimation(.linear(duration: .Animations.itemLongpress)) {
                scaleEffectSize = .ScaleEffect.original
                nameColor = .primary
            } completion: {
                UIPasteboard.general.string = item.name
                presentAlert = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        VStack {
            List {
                BlueprintItemRowView(item: BlueprintItem("Avocado"))
                BlueprintItemRowView(item: BlueprintItem("Bananas"))
                BlueprintItemRowView(item: BlueprintItem("Tomatoes"))
                BlueprintItemRowView(item: BlueprintItem("Eggs"))
                BlueprintItemRowView(item: BlueprintItem("Wine"))
            }
        }
        .navigationTitle("Groceries")
    }
}
