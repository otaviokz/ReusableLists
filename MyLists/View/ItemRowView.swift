//
//  ItemRowView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 09/01/2024.
//

import SwiftUI

struct ItemRowView: View {
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
                    item.done.toggle()
                }
        }
    }
}

#Preview {
    VStack {
        ItemRowView(item: ListItem(name: "Some item"))
        ItemRowView(item: ListItem(name: "Another item"))
        ItemRowView(item: ListItem(name: "Yet another item"))
    }
    
}
