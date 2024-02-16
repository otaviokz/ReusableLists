//
//  ItemsView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

struct ListItemsView: View {
    @Environment(\.modelContext) var modelContext
    @State var list: ToDoList
    @State var showSortSheet: Bool = false
    @State var sortType: SortType = .doneLast
    
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
                ForEach(list.items.sorted(type: sortType)) { item in
                    ListItemRowView(item: item)
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        let item = list.items.sorted(type: sortType)[index]
                        guard let translatedIndex = list.items.firstIndex(of: item) else {
                            fatalError("Item not found in ToDoList.items!")
                        }
                        list.items.remove(at: translatedIndex)
                    }
                }
            }
        }
        .navigationTitle(list.name)
        .toolbar {
            HStack(spacing: 0) {
                Button("Sort", systemImage: "arrow.up.arrow.down") {
                    showSortSheet.toggle()
                }
                
                NavigationLink(destination: {
                    AddItemView(list, item: ListItem())
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
        .sheet(isPresented: $showSortSheet) {
            VStack {
                List {
                    Section("Sort by:") {
                        Text("Done last")
                            .onTapGesture { setSortTo(.doneLast) }
                        
                        Text("Done first")
                            .onTapGesture { setSortTo(.doneFirst) }
                        
                        Text("Priority")
                            .onTapGesture { setSortTo(.priority) }
                    }
                    .font(.headline)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.automatic)
        }
        
    }
}

// MARK: - Private Methods
private extension ListItemsView {
    func setSortTo(_ type: SortType) {
        sortType = type
        showSortSheet = false
    }
}

#Preview {
    let list = ToDoList(name: "Sample List")
    list.items = [ListItem(name: "Item1", done: true), ListItem(name: "Item2")]
    return NavigationStack {
        ListItemsView(list)
    }
}
