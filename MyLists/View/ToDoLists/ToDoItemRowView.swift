//
//  ToDoItemRowView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 09/01/2024.
//

import SwiftUI

struct ToDoItemRowView: View {
    @State private var showAlert = false
    let item: ToDoItem
    
    var body: some View {
        ZStack {
            HStack {
                Text(item.name)
                    .font(.headline.weight(.medium))
                Spacer()
                (item.done ? Images.checkBoxTicked : Images.checkBox)
                    .sizedToFit()
                    .foregroundStyle(Color.cyan)
                    .onTapGesture {
                        withAnimation {
                            item.done.toggle()
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
}

#Preview {
    VStack {
        ToDoItemRowView(item: ToDoItem(name: "Some item"))
        ToDoItemRowView(item: ToDoItem(name: "Another item"))
        ToDoItemRowView(item: ToDoItem(name: "Yet another item"))
    }
}
