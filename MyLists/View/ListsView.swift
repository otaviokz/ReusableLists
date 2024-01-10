//
//  ListsView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

struct ListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var lists: [ToDoList]
    @State private var sortOrder: SortDescriptor<ToDoList> = SortDescriptor(\ToDoList.name)
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }
    init() {
        _lists = Query(
            filter: #Predicate { !$0.name.isEmpty },
            sort: [.init(\ToDoList.name)]
        )
    }
    
    var body: some View {
        List {            
            ForEach(lists) { list in
                NavigationLink(destination: ItemsView(list)) {
                    ToDoListRowView(list: list)
                }
            }
            .onDelete(perform: deleteLists)
        }
        .toolbar {
            NavigationLink(destination: {
                AddOrEditListView(ToDoList())
            }, label: {
                Button("Add list", systemImage: "plus") {}
            })
            
        }
        .navigationTitle("Lists")
        .onShake {
            modelContext.undoManager?.undo()
        }
    }
    
    private func deleteLists(_ indexSet: IndexSet) {
        for index in indexSet {
            let list = lists[index]
            modelContext.delete(list)
        }
    }
}

#Preview {
    NavigationStack {    
        ListsView()
    }
}
