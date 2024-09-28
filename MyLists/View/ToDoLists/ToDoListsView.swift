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
    @State var showAddToDoListSheet = false
    
    var body: some View {
        List {
            ForEach(lists)  { list in
                NavigationLink(destination: ToDoItemsListView(list: list)) {
                    listRow(for: list)
                }
            }
            .onDelete { indexSet in
                do {
                    try deleteLists(indexSet)
                } catch {
                    showErrorAlert = true
                }
            }
        }
        .toolbar {
            Image.plus
                .foregroundStyle(Color.cyan)
                .padding(.trailing, 4)
                .onTapGesture {
                    showAddToDoListSheet = true
                }
        }
        .sheet(isPresented: $showAddToDoListSheet) {
            NewListOrBlueprintView(isSheetPresented: $showAddToDoListSheet, entity: .toDoList)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            focusState = .name
        }
        .navigationTitle("Lists")
    }
}

// MARK: - UI

private extension ToDoListsView {
    enum Field: Hashable {
        case name
    }
    
    func listRow(for list: ToDoList) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(list.name).font(.title3.weight(.medium))
                HStack(spacing: 0) {
                    if !list.items.isEmpty && list.doneItems.count != list.items.count {
                        Text("☑")
                            .font(.headline.weight(.regular))
                        Text(": \(list.doneItems.count) of \(list.items.count)")
                        
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

// MARK: - SwiftData

private extension ToDoListsView {
    func deleteLists(_ indexSet: IndexSet) throws {
        guard let index = indexSet.first else {
            throw  ListError.deleteEntityIndexNotFound
        }
        modelContext.delete(lists[index])
        try modelContext.save()
    }
}

#Preview {
    NavigationStack {    
        ToDoListsView()
    }
}
