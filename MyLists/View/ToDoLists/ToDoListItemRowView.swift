//
//  ToDoListItemRowView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 09/01/2024.
//

import SwiftUI

struct ToDoListItemRowView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var showAlert = false
    let item: ToDoItem
    
    var body: some View {
        HStack {
            Text(item.name)
                .font(.headline.weight(.medium))
            Spacer()
            
            Image.imageForItem(item)
                .sizedToFit()
                .foregroundStyle(Color.cyan)
                .onTapGesture {
                    withAnimation {
                        item.done.toggle()
                        try? modelContext.save()
                    }
                }
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
        ToDoListItemRowView(item: ToDoItem(name: "Bananas"))
        ToDoListItemRowView(item: ToDoItem(name: "Tomatoes"))
        ToDoListItemRowView(item: ToDoItem(name: "Eggs"))
    }
}
