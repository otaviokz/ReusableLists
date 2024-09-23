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
    @FocusState private var focusState: Field?
    @State var showAddNewItem = false
    @State var itemName: String = ""
    @State var itemDone: Bool = false
    @State var showErrorAlert = false
    @State var showAddList = false
    
    var body: some View {
        List {
            ForEach(lists) { list in
                NavigationLink(destination: ToDoItemsListView(list: list)) {
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
                            gaugeView(list: list)
                        }
                    }
                }
            }
            .onDelete(perform: deleteLists)
        }
        .toolbar {
            Images.plus
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
                Text("\(Formatters.noDecimals.string(from: NSNumber(value: list.completion * 100)) ?? "0")%")
                    .font(.body)
            } else {
                Images.checkMark
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
