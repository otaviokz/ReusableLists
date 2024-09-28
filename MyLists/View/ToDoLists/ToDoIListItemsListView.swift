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
    @Environment(\.dismiss) var dismiss
    
    @Query(sort: [SortDescriptor(\ToDoItem.name, order: .forward)]) private var items: [ToDoItem]
    @Query(sort: [SortDescriptor(\Blueprint.name, order: .forward)]) private var Blueprints: [Blueprint]
    
    @State var showSortSheet: Bool = false
    @State var sortType: SortType = .doneLast
    @State var showAlert = false
    @State var alerMessage = Alert.defaultErrorMessage
    @State var showAddItemSheet = false
//    @State var showConfirmationSheet = false
    
    let list: ToDoList
    
    var body: some View {
        List {
            if !list.details.isEmpty {
                Section("Details") {
                    Text(list.details).font(.title3)
                }
            }
            
            Section("Items") {
                ForEach(list.items.sorted(type: sortType)) { item in
                    ToDoListItemRowView(item: item)
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        do {
                            let item = list.items.sorted(type: sortType)[index]
                            try delete(item: item)
                        } catch {
                            alerMessage = Alert.defaultErrorTitle
                            showAlert = true
                        }
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
        .sheet(isPresented: $showAddItemSheet) {
            AddToDoItemView(list, isSheetPresented: $showAddItemSheet)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
//        .actionSheet(isPresented: $showConfirmationSheet) {
//            ActionSheet(
//                title: Text("Are you sure you want to delete \"\(list.name)\" and all its itens?"),
//                message: nil,
//                buttons: [
//                    .cancel(Text("Cancel")) { },
//                    .destructive(Text("Yes")) {
//                        do {
//                            dismiss()
//                            try delete(list: list)
//                        } catch {
//                            showAlert = true
//                        }
//                    }
//                ]
//            )
//        }
        .alert(isPresented: $showAlert) {
            Alert(Alert.defaultErrorTitle, message: alerMessage)
        }
        .navigationTitle("\u{2611}  \(list.name)")
    }
}

// MARK: - Private Methods
private extension ToDoItemsListView {
    var toolBarView: some View {
        HStack(spacing: 12) {
//            Image.trash.sizedToFit()
//                .foregroundStyle(Color.red)
//                .onTapGesture {
//                    showConfirmationSheet = true
//                }
//                .padding(.trailing, -8)
//            
            NavigationLink {
                UpdateToDoListView(list)
            } label: {
                Image.gear.sizedToFit()
            }
            
            if list.items.count > 1 {
                Image.sort
                    .sizedToFit()
                    .onTapGesture {
                        showSortSheet = true
                    }
            }
            
            if !blueprintExistsFor(list: list) {
                createBlueprintIconButton
            }
            
            Image.plus
                .onTapGesture {
                    showAddItemSheet = true
                }
        }
        .foregroundStyle(Color.cyan)
        .padding(.trailing, 4)
    }
    
    var sortSheetView: some View {
        List {
            Section("Sort by:") {
                hstackFor(label: "Done first", value: AnyView(Image.checkBoxTicked.sizedToFit()))
                    .onTapGesture { setSortTo(.doneFirst) }
                
                hstackFor(label: "Todo first", value: AnyView(Image.checkBox.sizedToFit()))
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


// MARK: - UI
private extension ToDoItemsListView {
    var createBlueprintIconButton: some View {
        Image.docOnDoc
            .sizedToFit(width: 21.5, height: 21.5)
            .onTapGesture {
                createBlueprint(from: list)
            }
    }
}

// MARK: - SwiftData
fileprivate extension ToDoItemsListView {
    func blueprintExistsFor(list: ToDoList) -> Bool {
        Blueprints.first { $0.name.trimLowcaseEquals(list.name) } != nil
    }
    
    func createBlueprint(from list: ToDoList) {
        alerMessage = Alert.defaultErrorMessage
        do {
            guard !blueprintExistsFor(list: list) else {
                throw ListError.blueprintExistsForList(named: list.name)
            }
            let newBlueprint = Blueprint(name: list.name, details: list.details)
            newBlueprint.items = list.items.map { $0.asBlueprintItem }
            modelContext.insert(newBlueprint)
            try modelContext.save()
        } catch let error as ListError {
            if case ListError.blueprintExistsForList(named: list.name) = error {
                alerMessage = error.message
            }
            showAlert = true
        } catch {
            showAlert = true
        }
    }
    
    func delete(list: ToDoList) throws {
        modelContext.delete(list)
        try modelContext.save()
    }
    
    func deleteItem(_ indexSet: IndexSet) {
        alerMessage = Alert.defaultErrorMessage
        do {
            guard let index = indexSet.first else { throw ListError.deleteEntityIndexNotFound }
            let item = items[index]
            list.items = list.items.filter { $0 != item }
            modelContext.delete(item)
            try modelContext.save()
        } catch {
            showAlert = true
        }
    }
    
    func delete(item: ToDoItem) throws {
        list.items = list.items.filter { $0 != item }
        modelContext.delete(item)
        try modelContext.save()
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var list = ToDoList(
        name: "Groceries",
        items: [ToDoItem(name: "Letuce"), ToDoItem(name: "Bananas"), ToDoItem(name: "Eggs")]
    )
    
    NavigationStack {
        ToDoItemsListView(list: list)
    }
}

private extension ToDoList {
    convenience init(name: String = "", details: String = "", items: [ToDoItem]) {
        self.init(name: name, details: details)
        self.items = items
    }
}
