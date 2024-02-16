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
            Text(item.name)
                .font(.title3)
            Spacer()
            Image(systemName: "circle.fill")
                .foregroundColor(item.priority.color)
            Image(systemName: item.done ? "checkmark.square" : "square")
                .onTapGesture {
                    withAnimation {
                        item.done.toggle()
                    }
                }
        }
    }
}

#Preview {
    VStack {
        ListItemRowView(item: ListItem(name: "Some item"))
        ListItemRowView(item: ListItem(name: "Another item"))
        ListItemRowView(item: ListItem(name: "Yet another item"))
    }
}
