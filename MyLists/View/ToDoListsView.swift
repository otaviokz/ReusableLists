//
//  ListsView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

struct ToDoListsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        sort: [
            SortDescriptor(\ToDoList.name),
            SortDescriptor(\ToDoList.creationDate, order: .reverse)
        ]) private var lists: [ToDoList]
        
    var body: some View {
        List {            
            ForEach(lists) { list in
                NavigationLink(destination: ListItemsView(list)) {
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
    }
}

// MARK: - Private Methods
private extension ToDoListsView {
    func deleteLists(_ indexSet: IndexSet) {
        for index in indexSet {
            let list = lists[index]
            modelContext.delete(list)
        }
    }
}

#Preview {
    NavigationStack {    
        ToDoListsView()
    }
}
