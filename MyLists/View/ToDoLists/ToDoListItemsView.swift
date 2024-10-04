//
//  ItemsView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData
import Combine

struct ToDoListItemsView: View {
    @Environment(\.modelContext) var modelContext

    @Query(sort: [SortDescriptor(\Blueprint.name)]) private var blueprints: [Blueprint]
        
    @State var presentAlert = false
    @State var alerMessage = Alert.gnericErrorMessage
    @State var presentAddItemSheet = false
    @State var showSortSheet: Bool = false
    @State var sortType: SortType = .todoFirst
    @State var showDetails = false
    
    let list: ToDoList
    
    init(for list: ToDoList) {
        self.list = list
    }
    
    var body: some View {
        VStack {
            List {
                if !list.details.isEmpty {
                    Section("Details:") {
                        Text(list.details).font(.title3)
                            .foregroundStyle(Color.primary)
                    }
                }
                
                if !list.items.isEmpty {
                    Section("Items:") {
                        ForEach(list.items.sorted(by: sortType)) { item in
                            ToDoListItemRowView(item: item)
                        }
                        .onDelete(perform: deleteItem)
                    }
                }
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.cyan)
            .sheet(isPresented: $showSortSheet) {
                sortView
            }
            .sheet(isPresented: $presentAddItemSheet) {
                AddToDoItemView(list, isSheetPresented: $presentAddItemSheet)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .alert(isPresented: $presentAlert) {
                Alert(Alert.genericErrorTitle, message: alerMessage)
            }
            .toolbar {
                toolBarView
            }
            .navigationTitle(list.name)
        }
    }
}

// MARK: - UI
private extension ToDoListItemsView {
    var toolBarView: some View {
        HStack(spacing: 16) {
            NavigationLink {
                UpdateToDoListView(list)
            } label: {
                Image.gear.sizedToFit(width: 21, height: 21)
                    .padding(.top, 1.5)
            }
            
            if list.items.count > 1 {
                Image.sort.sizedToFit(height: 18).onTapGesture { showSortSheet = true }
            }
            
            if !blueprintAlreadyExistsFor(list: list) {
                Image.blueprint.sizedToFit().onTapGesture {
                    addBlueprint(from: list)
                }
            }
            
            Image.plus.onTapGesture { presentAddItemSheet = true }
                .padding(.leading, -4)
        }
        .foregroundStyle(Color.cyan)
        .padding(.trailing, 4)
    }
    
    var sortView: some View {
        List {
            Section("Sort by:") {
                sortOption("Todo first:", icon: .checkBox, sortyType: .todoFirst)
                
                sortOption("Done first:", icon: .checkBoxTicked, sortyType: .doneFirst)
                
                sortOption("Alphabetically:", icon: .az, sortyType: .alphabetic)
            }
            .font(.headline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    func setSortTo(_ type: SortType) {
        withAnimation {
            sortType = type
            showSortSheet = false
        }
    }
    
    func sortOption(_ label: String, icon: Image, sortyType: SortType) -> some View {
        HStack {
            icon.sizedToFitSquare()
            Spacer().frame(width: 12)
            Text(label).font(.headline)
            Spacer()
            if self.sortType == sortyType {
                Image.checkMark
            }
        }
        // It needs to specify content shape to cover all area, since by default only opaque views handle gesture
        // https://stackoverflow.com/a/62640126/884744
        .contentShape(Rectangle())
        .foregroundStyle(Color.cyan)
        .onTapGesture { setSortTo(sortyType) }
    }
}

// MARK: - SwiftData

fileprivate extension ToDoListItemsView {
    
    func blueprintAlreadyExistsFor(list: ToDoList) -> Bool {
        blueprints.first { $0.name.trimLowcaseEquals(list.name) } != nil
    }
    
    func addBlueprint(from list: ToDoList) {
        alerMessage = Alert.gnericErrorMessage
        do {
            guard !blueprintAlreadyExistsFor(list: list) else {
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
            presentAlert = true
        } catch {
            presentAlert = true
        }
    }
    
    func deleteItem(_ indexSet: IndexSet) {
        do {
            guard let index = indexSet.first else { throw ListError.emptyDeleteIndexSet }
            let item = list.items.sorted(by: sortType)[index]
            list.items = list.items.filter { $0 != item }
            modelContext.delete(item)
            try modelContext.save()
        } catch {
            alerMessage = Alert.gnericErrorMessage
            presentAlert = true
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var list = ToDoList(
        "Groceries",
        items: [ToDoItem("Letuce"), ToDoItem("Bananas"), ToDoItem("Eggs")]
    )
    
    NavigationStack { ToDoListItemsView(for: list) }
}

