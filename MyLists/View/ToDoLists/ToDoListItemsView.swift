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
    @EnvironmentObject private var tabselection: TabSelection
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: [SortDescriptor(\Blueprint.name)]) private var blueprints: [Blueprint]
        
    @State var presentAlert = false
    @State var alerMessage = Alert.gnericErrorMessage
    @State var presentAddItemSheet = false
    @State var showSortSheet: Bool = false
    @State var sortType: SortType = .todoFirst
    @State var showDetails = false
    @State var showListToBlueprint = false
    @State var presentDeleteOption = false
    
    let list: ToDoList
    
    init(for list: ToDoList) {
        self.list = list
    }
    
    var body: some View {
        VStack {
            List {
                if !list.details.isEmpty {
                    Section("List Details:") {
                        Text(list.details).font(.title3)
                            .foregroundStyle(Color.primary)
                    }
                }
                
                if !list.items.isEmpty {
                    Section("List Items:") {
                        ForEach(list.items.sorted(by: sortType)) { item in
                            ToDoListItemRowView(item: item) { presentDeleteOptionIfCompleted() }
                        }
                        .onDelete(perform: deleteItem)
                    }
                }
            }
            .actionSheet(isPresented: $presentDeleteOption) {
                ActionSheet(
                    title: Text("List completed!"),
                    message: Text("Would you like to delete it now it's completed?"),
                    buttons: [ActionSheet.Button.destructive(Text("Yes")) { deleteList() }, .cancel(Text("Cancel"))]
                )
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
                Alert(title: Alert.genericErrorTitle, message: alerMessage)
            }
            
            .toolbar {
                toolBarView
            }
            .onAppear {
                if tabselection.selectedTab == 1 && tabselection.shouldPopToRootView {
                    dismiss()
                    tabselection.didPopToRootView()
                }
            }
            .navigationTitle(list.name)
            
        }
    }
}

// MARK: - UI

private extension ToDoListItemsView {
    func presentDeleteOptionIfCompleted() {
        if list.doneItems.count == list.items.count {
            presentDeleteOption = true
        }
    }
                      
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
            
//            if !blueprintAlreadyExistsFor(list: list) && showListToBlueprint {
//                Image.blueprint.sizedToFit().onTapGesture {
//                    addBlueprint(from: list)
//                }
//            }
            
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
        .presentationDetents([.fraction(0.35)])
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
    
    func deleteList() {
        dismiss()
        Task {
            do {
                try await Task.sleep(nanoseconds: 450_000_000)
                try withAnimation {
                    modelContext.delete(list)
                    try modelContext.save()
                }
            } catch {
                alerMessage = Alert.gnericErrorMessage
                presentAlert = true
            }
        }
    }
}

// MARK: - Preview
// #Preview {
//    @Previewable @State var list = ToDoList(
//        "Groceries",
//        details: "Try farmers market first",
//        items:
//            [ToDoItem("Letuce"), ToDoItem("Bananas"), ToDoItem("Eggs")]
//    )
//    
//    NavigationStack { ToDoListItemsView(for: list) }
// }
