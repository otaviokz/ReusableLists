//
//  ItemsView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

struct ToDoItemsListView: View {
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
                    ToDoItemRowView(item: item)
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
                if list.items.count > 1 {
                    Button("Sort", systemImage: "arrow.up.arrow.down") {
                        showSortSheet.toggle()
                    }
                }
                NavigationLink(destination: {
                    AddToDoItemView(list)
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
        .sheet(isPresented: $showSortSheet) {
            VStack {
                List {
                    Section("Sort by:") {
                        HStack {
                            Text("Priority")
                            Spacer()
                            Priority.high.coloredCircle
                            Priority.medium.coloredCircle
                            Priority.low.coloredCircle
                        }
                        .onTapGesture { setSortTo(.priority) }
                        
                        HStack {
                            Text("Done first")
                            Spacer()
                            Image(systemName: "checkmark.square")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .onTapGesture { setSortTo(.doneFirst) }
                        
                        HStack {
                            Text("Todo first")
                            Spacer()
                            Image(systemName: "square")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .onTapGesture { setSortTo(.doneLast) }
                        
                        HStack{
                            Text("Alphabetic")
                            Spacer()
                            Text("A-Z")
                        }
                        .onTapGesture { setSortTo(.alphabetic) }
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
private extension ToDoItemsListView {
    func setSortTo(_ type: SortType) {
        sortType = type
        showSortSheet = false
    }
}

#Preview {
    let list = ToDoList(name: "Sample List")
    list.items = [ToDoItem(name: "Item1", done: true), ToDoItem(name: "Item2")]
    return NavigationStack {
        ToDoItemsListView(list)
    }
}
