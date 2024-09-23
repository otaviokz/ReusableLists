//
//  ToDoListRowView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 02/01/2024.
//

import SwiftUI

struct ToDoListRowView: View, NoDecimalsNumberFormattable {
    
    var list: ToDoList
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(list.name)
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text(list.creationDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.footnote)
            }
            
            Spacer()
            
            if !list.items.isEmpty {
                Gauge(value: list.completion, in: 0...1) {
                    if list.completion < 1 {
                        Text("\(Self.noDecimalsFormatter.string(for: list.completion * 100) ?? "0")")
                    } else {
                        Images.checkMark
                            .sizedToFit(width: 16, height: 16)
                            .foregroundColor(.cyan)
                    }
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .scaleEffect(CGSize(width: 0.7, height: 0.7))
                .tint(.cyan)
            }
        }
    }
}

#Preview {
    ToDoListRowView(list: ToDoList(name: "List Row Preview"))
}
