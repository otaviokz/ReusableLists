//
//  ItemsView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData
import Combine

struct ToDoItemsListView: View {
    @Environment(\.modelContext) var modelContext
//    @EnvironmentObject var tabSelection: TabSelection
    @Environment(\.dismiss) var dismiss
    @Query(sort: [SortDescriptor(\Blueprint.name)]) private var blueprints: [Blueprint]
    @State var showSortSheet: Bool = false
    @State var sortType: SortType = .doneLast
    @State var showAddNewItem = false
    @State var showAlert = false
    let list: ToDoList
    
    
    var body: some View {
        List {
            if !list.details.isEmpty {
                Section("Details") {
                    Text(list.details)
                        .font(.title3)
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
        .toolbar {
            toolBarView
        }
        .sheet(isPresented: $showSortSheet) {
            sortSheetView
        }
        .sheet(isPresented: $showAddNewItem) {
            AddToDoItemView(list, isSheetPresented: $showAddNewItem)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .alert(isPresented: $showAlert) {
            Alert.genericErrorAlert
        }
        .navigationTitle("\u{2611}  \(list.name)")
//        .onReceive(Just(tabSelection)) { newValue in
//            if tabSelection.selectedTab == 1 && tabSelection.lastSelectedTab == 2 {
//                dismiss()
//            }
//        }
    }
}

// MARK: - Private Methods
private extension ToDoItemsListView {
    var toolBarView: some View {
        HStack(spacing: 12) {
            NavigationLink {
                UpdateToDoListView(list)
            } label: {
                Images.gear.sizedToFit()
            }
            
            if list.items.count > 1 {
                Images.sort
                    .sizedToFit()
                    .onTapGesture {
                        showSortSheet = true
                    }
            }
            
            if !blueprintExistsFor(list) {
                Images.docOnDoc
                    .sizedToFit(width: 21.5, height: 21.5)
                    .onTapGesture {
                        do {
                            try createBlueprint(from: list)
                        } catch {
                            showAlert = true
                        }
                    }
            }
            
            Images.plus
                .onTapGesture {
                    showAddNewItem = true
                }
        }
        .foregroundStyle(Color.cyan)
        .padding(.trailing, 4)
    }
    
    var sortSheetView: some View {
        List {
            Section("Sort by:") {
                hstackFor(label: "Done first", value: AnyView(Images.checkBoxTicked.sizedToFit()))
                    .onTapGesture { setSortTo(.doneFirst) }
                
                hstackFor(label: "Todo first", value: AnyView(Images.checkBox.sizedToFit()))
                    .onTapGesture { setSortTo(.doneLast) }
                
                hstackFor(label: "Alphabetic", value: AnyView(Text("A-Z")))
                    .onTapGesture { setSortTo(.alphabetic) }
            }
            .font(.headline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    func hstackFor(label: String, value: AnyView) -> some View {
        HStack {
            Text(label)
            Spacer()
            value
        }
    }
    
    func setSortTo(_ type: SortType) {
        withAnimation {
            sortType = type
            showSortSheet = false
        }
        
    }
}

private extension ToDoItemsListView {
    func blueprintExistsFor(_ list: ToDoList) -> Bool {
        blueprints.first { $0.name == list.name} != nil
    }
    
    func createBlueprint(from list: ToDoList) throws {
        if blueprintExistsFor(list) {
            throw ListError.blueprintNameUnavailable(list.name)
        }
        
        let blueprint = Blueprint(name: list.name, details: list.details)
        blueprint.items = list.items.asBlueprintItems()
        modelContext.insert(blueprint)
        
        try modelContext.save()
    }
}

#Preview {
    let list = ToDoList(name: "Sample List")
    list.items = [ToDoItem(name: "Item1", done: true), ToDoItem(name: "Item2")]
    return NavigationStack {
        ToDoItemsListView(list: list)
    }
}
