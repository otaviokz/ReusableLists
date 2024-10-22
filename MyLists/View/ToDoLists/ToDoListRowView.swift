//
//  ToDoListRowView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 19/10/2024.
//

import SwiftUI

struct ToDoListRowView: View {
    let list: ToDoList
    @State private var items: [ToDoItem] = []
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text(list.name).font(.title3.weight(.medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                HStack(spacing: 0) {
                    if !items.isEmpty && items.doneItems.count != items.count {
                        Text("☑").font(.headline.weight(.regular))
                        Text(": \(items.doneItems.count) of \(items.count)")
                    } else if !items.isEmpty {
                        Text("✓ ").font(.headline.weight(.semibold))
                        Text("Complete")
                    } else {
                        Text("Empty")
                    }
                }
                .font(.callout.weight(.light)).opacity(0.725)
            }
           
            Spacer()
            
            if !list.items.isEmpty  && !list.doneItems.isEmpty {
                gaugeView(list: list)
            }
        }
        .foregroundStyle(Color.cyan)
        .task {
            items = list.items
        }
    }
}

// MARK: - UI

private extension ToDoListRowView {
    func gaugeView(list: ToDoList) -> some View {
        Gauge(value: list.completion, in: 0...Double(1)) {
            if list.completion < 1 {
                Text("\(NumberFormatter.noDecimals.string(from: NSNumber(value: list.completion * 100)) ?? "0")%")
                    .font(.body)
            } else {
                Image.checkMark
                    .sizedToFitSquare(side: 16)
                    .foregroundColor(.cyan)
            }
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .scaleEffect(CGSize(width: 0.7, height: 0.7))
        .tint(.cyan)
    }
}

#Preview {
    ToDoListRowView(list: ToDoList("Sample list", details: ""))
        .padding()
}
