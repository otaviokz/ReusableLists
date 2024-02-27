//
//  ItemRowView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 09/01/2024.
//

import SwiftUI

struct ToDoItemRowView: View {
    let item: ToDoItem
    @State private var showAlert = false
    
    var body: some View {
        HStack {
            Image(systemName: item.done ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 20, height: 20)
                .onTapGesture {
                    withAnimation {
                        item.done.toggle()
                    }
                }
            Text(item.name)
                .font(.title3)
            Spacer()
            item.priority.coloredCircle
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
        ToDoItemRowView(item: ToDoItem(name: "Some item"))
        ToDoItemRowView(item: ToDoItem(name: "Another item"))
        ToDoItemRowView(item: ToDoItem(name: "Yet another item"))
    }
}
