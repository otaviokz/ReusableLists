//
//  ItemRowView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 09/01/2024.
//

import SwiftUI

struct ListItemRowView: View {
    let item: ListItem
    
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
    }
}

#Preview {
    VStack {
        let list = ToDoList(name: "Preview List", details: "")
        ListItemRowView(item: ListItem(name: "Some item", list: list))
        ListItemRowView(item: ListItem(name: "Another item", list: list))
        ListItemRowView(item: ListItem(name: "Yet another item", list: list))
    }
}
