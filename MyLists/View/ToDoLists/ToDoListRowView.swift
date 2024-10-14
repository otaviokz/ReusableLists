//
//  ToDoListRowView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 02/01/2024.
//

import SwiftUI
import SwiftData

/**********************************************************
 * Not in use as it doen't update the number of items done and the gauge view  *
 **********************************************************
 */

/*struct ToDoListRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\ToDoItem.name, order: .forward)]) private var items: [ToDoItem]
    
    let list: ToDoList
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(list.name)
                    .font(.title3)
                    .fontWeight(.medium)
                
                if !list.items.isEmpty {
                    Text("Done: \(list.items.doneItems.count) out of \(list.items.count)").font(.footnote)
                } else {
                    Text("Empty").font(.footnote)
                }
            }
            
            Spacer()
            
            if !list.items.isEmpty {
                Gauge(value: list.completion, in: 0...1) {
                    if list.completion < 1 {
                        Text("\(NumberFormatter.noDecimals.string(for: list.completion * 100) ?? "0")")
                    } else {
                        Image.checkMark
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

*/
