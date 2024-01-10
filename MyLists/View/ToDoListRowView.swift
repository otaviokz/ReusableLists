//
//  ToDoListRowView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 02/01/2024.
//

import SwiftUI

struct ToDoListRowView: View {
    var list: ToDoList
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
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
                        Text("\(numberFormatter.string(from: NSNumber(value: list.completion * 100)) ?? "0")%")
                            .font(.body)
                    } else {
                        Image(systemName: "checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
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

private extension ToDoList {
    var completion: Double {
        min(1, Double(items.filter { $0.done }.count) / Double(items.count))
    }
}

#Preview {
    ToDoListRowView(list: ToDoList(name: "List Row Preview"))
}
