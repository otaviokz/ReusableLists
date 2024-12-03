//
//  ItemsView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

struct ToDoListItemsView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject private var tabselection: TabSelection
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\Blueprint.name)]) private var blueprints: [Blueprint]
        
    @State var presentAlert = false
    @State var alerMessage = Alert.genericErrorMessage
    @State var presentAddItemSheet = false
    @State var showSortSheet: Bool = false
    @State var showDetails = false
    @State var showListToBlueprint = false
    @State var presentDeleteOption = false
    
    let list: ToDoList
    let allDoneAction: (ToDoList) -> Void
    
    init(for list: ToDoList, allDoneAction: @escaping (ToDoList) -> Void) {
        self.list = list
        self.allDoneAction = allDoneAction
    }
    
    var body: some View {
        VStack {
            if !list.items.isEmpty {
                Gauge(value: list.completion) { }
                    .animation(.linear(duration: 0.25), value: list.completion)
                    .tint(.green)
                    .padding(.horizontal, 22)
            }
            
            List {
                if !list.details.isEmpty {
                    Section("List Details:") {
                        Text(list.details).font(.title3)
                            .foregroundStyle(Color.primary)
                    }
                }
                
                if !list.items.isEmpty {
                    Section("List Items  -  ⇅: \(list.sortType.rawValue.lowercased())") {
                        ForEach(list.items.sorted(by: list.sortType)) { item in
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
                    buttons: [ActionSheet.Button.destructive(Text("Yes")) {
                        dismiss()
                        allDoneAction(list)
                    }, .cancel(Text("Cancel"))]
                )
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.cyan)
            .sheet(isPresented: $showSortSheet) {
                sortView
            }
            .sheet(isPresented: $presentAddItemSheet) {
                NewListOrBlueprintItemFormView(
                    .toDoList(entity: list),
                    isSheetPresented: $presentAddItemSheet,
                    isUniqueNameInEntity: isUniqueNameInEntity,
                    createAndInsertNewItems: createAndInsertNewItems
                )
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .alert(isPresented: $presentAlert) {
            Alert(title: Alert.genericErrorTitle, message: alerMessage)
        }
        .toolbar {
            toolBarView
        }
        .task {
            setSortBy(list.sortType)
        }
        .onAppear {
            if tabselection.selectedTab == 1 && tabselection.shouldPopToRootView {
                Task {
                    do {
                        withAnimation(.easeIn(duration: 0.25)) {
                            dismiss()
                            tabselection.didPopToRootView()
                        }
                        try await Task.sleep(nanoseconds: WaitTimes.dismiss)
                    } catch {
                        logger.error("Error dismissing ToDoListItemsView: \(error)")
                    }
                }
            }
        }
        .navigationTitle(list.name)
    }

}

// MARK: - UI

private extension ToDoListItemsView {
    var shareMessage: String {
        var string = "Name:  " + list.name
        if !list.details.isEmpty {
            string += "\n\nDetails:\n\n\(list.details)"
        }
        
        string += "\n\n"
        
        for item in list.items.sorted(by: list.sortType) {
            string += " ▢  -  \(item.name)\n\n"
        }
        
        string += "Reusable Lists\n"
        string += "https://tinyurl.com/mr3essyr"
        
        return string
    }
    
    func presentDeleteOptionIfCompleted() {
        if list.completion >= 1 {
            presentDeleteOption = true
        }
    }
                      
    var toolBarView: some View {
        HStack(spacing: 16) {
            ShareLink(item: shareMessage) {
                Label("", systemImage: "square.and.arrow.up")
            }
            .padding(.trailing, -8)
            .padding(.top, -4)
            
            NavigationLink {
                UpdateToDoListView(list)
            } label: {
                Image.gear.sizedToFit(width: 21, height: 21)
                    .padding(.top, 1.5)
            }
            
            if list.items.count > 1 {
                Image.sort.sizedToFit(height: 18).onTapGesture { showSortSheet = true }
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
                
                sortOption("By Name:", icon: .az, sortyType: .byName)
                
                sortOption("By Name (reversed):", icon: .za, sortyType: .byNameInverted)
            }
            .font(.headline)
        }
        .presentationDetents([.fraction(0.35)])
        .presentationDragIndicator(.visible)
    }
    
    func setSortBy(_ type: SortType) {
        withAnimation {
            list.sortType = type
            showSortSheet = false
        }
        try? modelContext.save()
    }
    
    func sortOption(_ label: String, icon: Image, sortyType: SortType) -> some View {
        HStack {
            icon.sizedToFitSquare()
            Spacer().frame(width: 12)
            Text(label).font(.headline)
            Spacer()
            if list.sortType == sortyType {
                Image.checkMark
            }
        }
        // It needs to specify content shape to cover all area, since by default only opaque views handle gesture
        // https://stackoverflow.com/a/62640126/884744
        .contentShape(Rectangle())
        .foregroundStyle(Color.cyan)
        .onTapGesture { setSortBy(sortyType) }
    }
}

// MARK: - SwiftData

private extension ToDoListItemsView {
    func deleteItem(_ indexSet: IndexSet) {
        do {
            guard let index = indexSet.first else { throw ListError.emptyDeleteIndexSet }
            let item = list.items.sorted(by: list.sortType)[index]
            list.items = list.items.filter { $0 != item }
            modelContext.delete(item)
            try modelContext.save()
        } catch {
            logger.error("Error deleting ToDoItem: \(error)")
            alerMessage = Alert.genericErrorMessage
            presentAlert = true
        }
    }
}

extension ToDoListItemsView: NewItemCreatorProtocol {
    func isUniqueNameInEntity(name: String) -> Bool {
        list.items.first { $0.name.asInputLowercasedEquals(name) } == nil
    }
    
    func createAndInsertNewItems(names: [String]) throws {
        for name in names {
            let item = ToDoItem(name)
            list.items.append(item)
            modelContext.insert(item)
        }
        try modelContext.save()
    }
}
