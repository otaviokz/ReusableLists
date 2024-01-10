//
//  ItemsView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

struct ItemsView: View {
    @Environment(\.modelContext) var modelContext
    @ObservedObject var list: ToDoList
    @State var newItem: ListItem? = nil
    @State var didUndo = false
    
    
    init(_ list: ToDoList) {
        self.list = list
    }
    
    var body: some View {
        List {
            if !list.details.isEmpty {
                Section("Details") {
                    Text(list.details)
                }
            }
            
            Section("Items") {
                ForEach(list.items) { item in
                    ItemRowView(item: item)
                }
                .onDelete(perform: { indexSet in
                    if let index = indexSet.first  {
                        list.items.remove(at: index)
                    }
                })
            }
        }
        .navigationTitle(list.name)
        .toolbar {
            NavigationLink(destination: {
                AddItemView(list, item: newItem ?? ListItem())
            }, label: {
                Image(systemName: "plus")
            })
            
        }
        .onShake {
            if modelContext.undoManager?.canUndo ?? false {
                modelContext.undoManager?.undo()
            }
        }
    }
}

#Preview {
    let list = ToDoList(name: "Sample List")
    let items = [ListItem(name: "Item1", done: true), ListItem(name: "Item2")]
    list.items = items
    return NavigationStack {
        ItemsView(list)
    }
}

private extension Bool {
    var intValue: Int {
        self ? 1 : 0
    }
}
