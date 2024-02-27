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
    @Query(sort: [
        SortDescriptor(\ToDoList.name),
        SortDescriptor(\ToDoList.creationDate, order: .reverse)
    ]) private var lists: [ToDoList]
    static var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    var body: some View {
        List {
            ForEach(lists) { list in
                NavigationLink(destination: ToDoItemsListView(list)) {
//                    ToDoListRowView(list: list)
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
                            Gauge(value: list.completion, in :0...Double(1)) {
                                if list.completion < 1 {
                                    Text("\(Self.numberFormatter.string(from: NSNumber(value: list.completion * 100)) ?? "0")%")
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
            .onDelete(perform: deleteLists)
        }
        .toolbar {
            NavigationLink(destination: {
                NewToDoListView()
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
