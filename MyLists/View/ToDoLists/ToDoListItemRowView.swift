//
//  ToDoListItemRowView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 09/01/2024.
//

import SwiftUI

struct ToDoListItemRowView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var alertType: AlertType = .pasteboard
    @State private var presentAlert = false
    @State private var scaleEffectSize = CGSize.ScaleEffect.original
    @State private var nameColor = Color.primary
    
    let item: ToDoItem
    let onCheckedAsDone: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(item.name)
                .scaleEffect(scaleEffectSize)
                .font(.title3.weight(.light))
                .foregroundStyle(nameColor)
            
            Spacer()
                
            Image.checkBoxiImageForItem(item)
                .sizedToFit(width: 22, height: 22)
                .foregroundStyle(Color.cyan)
                .onTapGesture {
                    withAnimation(.linear(duration: .Animations.toggleDone)) {
                        toggleDone(for: item)
                    }
                }
                .padding(.top, 0.5)
                .scaleEffect(scaleEffectSize)
        }
        // It needs to specify content shape to cover all area, since by default only opaque views handle gesture
        // https://stackoverflow.com/a/62640126/884744
        .contentShape(Rectangle())
        .onLongPressGesture {
            copyNameToClipboard()
        }
        .alert(isPresented: $presentAlert) {
            switch alertType {
                case .pasteboard: Alert(title: "'\(item.name)' copied to Pasteboard", message: "")
                case .swiftDataError: Alert.genericError
            }
        }  
    }
}

// MARK: - UI

private extension ToDoListItemRowView {
    enum AlertType {
        case pasteboard
        case swiftDataError
    }
    
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
                alertType = .pasteboard
                presentAlert = true
            }
        }
    }
}

// MARK: - SwiftData

private extension ToDoListItemRowView {
    func toggleDone(for item: ToDoItem) {
        do {
            item.done.toggle()
            try modelContext.save()
            if item.done { onCheckedAsDone() }
        } catch {
            logger.error("Error saving item: (\(item.name)) after toggle done: \(error)")
            alertType = .swiftDataError
            presentAlert = true
            item.done.toggle()
        }
    }
}

#Preview {
    NavigationStack {
        VStack {
            List {
                ToDoListItemRowView(item: ToDoItem("Avocado")) { }
                ToDoListItemRowView(item: ToDoItem("Bananas")) { }
                ToDoListItemRowView(item: ToDoItem("Tomatoes")) { }
                ToDoListItemRowView(item: ToDoItem("Eggs", done: true)) { }
                ToDoListItemRowView(item: ToDoItem("Wine", done: true)) { }
            }
        }
        .navigationTitle("Groceries")
    }
}
