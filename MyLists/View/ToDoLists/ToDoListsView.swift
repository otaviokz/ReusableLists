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
    
    @Query(sort: [SortDescriptor(\ToDoList.name, order: .forward)]) private var lists: [ToDoList]
    
    @FocusState private var focusState: Field?
    @State var showAddNewItem = false
    @State var itemName: String = ""
    @State var itemDone: Bool = false
    @State var showErrorAlert = false
    @State var showAddList = false
    
    var body: some View {
        List {
            ForEach(lists)  { list in
                NavigationLink(destination: ToDoItemsListView(list: list)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(list.name).font(.title3.weight(.medium))
                            HStack(spacing: 0) {
                                if !list.items.isEmpty && list.doneItems.count != list.items.count {
                                    Text("☑")
                                        .font(.headline.weight(.regular))
                                    Text(": \(list.doneItems.count) of \(list.doneItems.count)")
                                    
                                } else if !list.items.isEmpty {
                                    Text("✓ ")
                                        .font(.headline.weight(.semibold))
                                    Text("Complete")
                                } else {
                                    Text("Empty")
                                }
                            }
                            .font(.callout.weight(.light))
                        }
                        
                        Spacer()
                        
                        if !list.items.isEmpty {
                            gaugeView(list: list)
                        }
                    }
                    .foregroundStyle(Color.cyan)
                }
            }
            .onDelete(perform: deleteLists)
        }
        .toolbar {
            Image.plus
                .foregroundStyle(Color.cyan)
                .padding(.trailing, 4)
                .onTapGesture {
                    showAddList = true
                }
        }
        .sheet(isPresented: $showAddList) {
            AddToDoListView(isSheetPresented: $showAddList)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            focusState = .name
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
    
    enum Field: Hashable {
        case name
    }
    
    func gaugeView(list: ToDoList) -> some View {
        Gauge(value: list.completion, in :0...Double(1)) {
            if list.completion < 1 {
                Text("\(NumberFormatter.noDecimals.string(from: NSNumber(value: list.completion * 100)) ?? "0")%")
                    .font(.body)
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

#Preview {
    NavigationStack {    
        ToDoListsView()
    }
}
