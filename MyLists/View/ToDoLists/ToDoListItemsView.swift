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
    @State var alertMessage = Alert.genericErrorMessage
    @State private var presentSheet = false
    @State private var sheetType: SheetType = .none
    @State private var showDeleteOptionActionSheet = false
    @State private var sortType: SortType = .doneLast
    @State private var showDetails = false
    @State private var showListToBlueprint = false
    @State private var presentDeleteOption = false
    
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
            
            listView
            .actionSheet(isPresented: $showDeleteOptionActionSheet) {
                deleteListOptionActionSheet
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.cyan)
            .sheet(isPresented: $presentSheet) {
                switch sheetType  {
                case .sort: sortView
                case .addItem:
                    NewListOrBlueprintItemFormView(
                        .toDoList(entity: list),
                        isSheetPresented: $presentSheet,
                        isUniqueNameInEntity: isUniqueNameInEntity,
                        createAndInsertNewItems: createAndInsertNewItems
                    )
                case .edit(let item):
                    EditToDoListItemFormView(item, list: list, isSheetPresented: $presentSheet) { save($0) }
                default: EmptyView()
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .alert(isPresented: $presentAlert) {
            Alert(title: Alert.genericErrorTitle, message: alertMessage)
        }
        .toolbar {
            toolBarView
        }
        .onAppear {
            checkPopToRootView()
        }
        .navigationTitle(list.name)
    }
}

// MARK: - Private Methods

private extension ToDoListItemsView {
    func checkPopToRootView() {
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
}

// MARK: - Edit Item

extension ToDoListItemsView {
    enum SheetType {
        case edit(item: ToDoItem)
        case sort
        case addItem
        case none
    }
}
// MARK: - UI

private extension ToDoListItemsView {
    var listView: some View {
        List {
            if !list.details.isEmpty {
                Section("List Details:") {
                    Text(list.details).font(.title3)
                        .foregroundStyle(Color.primary)
                }
            }
            
            if !list.items.isEmpty {
                itemsSection
            }
        }
    }
    
    var itemsSection: some View {
        Section("List Items:") {
            ForEach(list.items.sorted(by: sortType)) { item in
                ToDoListItemRowView(item: item) { presentDeleteOptionIfCompleted()
                }
                .swipeActions(edge: .leading) {
                    Button("Edit", role: .cancel) {
                        sheetType = .edit(item: item)
                        presentSheet = true
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        delete(item: item)
                    } label: {
                         Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
        }
    }
    
    var deleteListOptionActionSheet: ActionSheet {
        ActionSheet(
            title: Text("List completed!"),
            message: Text("Would you like to delete it now it's completed?"),
            buttons: [ActionSheet.Button.destructive(Text("Yes")) {
                dismiss()
                allDoneAction(list)
            },
            .cancel(Text("Cancel"))]
        )
    }
    
    var shareMessage: String {
        var string = "Name:  " + list.name
        if !list.details.isEmpty {
            string += "\n\nDetails:\n\n\(list.details)"
        }
        string += "\n\n"
        
        for item in list.items.sorted(by: sortType) { string += " ▢  -  \(item.name)\n\n" }
        
        string += "Reusable Lists\n"
        string += "https://tinyurl.com/mr3essyr"
        
        return string
    }
    
    func presentDeleteOptionIfCompleted() {
        showDeleteOptionActionSheet = list.completion >= 1
    }
                      
    var toolBarView: some View {
        HStack(spacing: 16) {
            ShareLink(item: shareMessage) { Label("", systemImage: "square.and.arrow.up") }
                .padding(.trailing, -8)
                .padding(.top, -4)
            
            NavigationLink { EditToDoListFormView(list) } label: { Image.gear.sizedToFit(width: 21, height: 21).padding(.top, 1.5) }
            
            if list.items.count > 1 {
                Image.sort.sizedToFit(height: 18).onTapGesture {
                    sheetType = .sort
                    presentSheet = true
                }
            }
            
            Image.plus.onTapGesture {
                sheetType = .addItem
                presentSheet = true
            }.padding(.leading, -4)
        }
        .foregroundStyle(Color.cyan)
        .padding(.trailing, 4)
    }
    
    var sortView: some View {
        List {
            Section("Sort by:") {
                sortOption("Todo first:", icon: .checkBox, sortyType: .doneLast)
                sortOption("Alphabetically:", icon: .az, sortyType: .alphabetic)
                sortOption("Done first:", icon: .checkBoxTicked, sortyType: .doneFirst)
            }
            .font(.headline)
        }
        .presentationDetents([.fraction(0.35)])
        .presentationDragIndicator(.visible)
    }
    
    func setSortTo(_ type: SortType) {
        withAnimation {
            sortType = type
            presentSheet = false
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

private extension ToDoListItemsView {
    func deleteItem(_ indexSet: IndexSet) throws {
        guard let index = indexSet.first else { throw ListError.emptyDeleteIndexSet }
        delete(item: list.items[index])
    }
    
    func delete(item: ToDoItem) {
        list.items = list.items.filter { $0 != item }
        modelContext.delete(item)
        do {
            try modelContext.save()
        } catch {
            logger.error("Error deleting ToDoItem: \(error)")
            alertMessage = Alert.genericErrorMessage
            presentAlert = true
        }
    }
    
    func save(_ item: ToDoItem) {
        do {
            try modelContext.save()
        } catch {
            logger.error("Error editing item: \(error)")
            alertMessage = Alert.genericErrorMessage
            presentAlert = true
        }
    }
}

// MARK: - NewItemCreatorProtocol

extension ToDoListItemsView: NewItemCreatorProtocol {
    func isUniqueNameInEntity(name: String) -> Bool {
        list.items.first { $0.name.asInputLowcaseEquals(name) } == nil
    }
    
    func createAndInsertNewItems(_ newItems: [(name: String, priority: Bool)]) throws {
        for item in newItems {
            let item = ToDoItem(item.name, priority: item.priority)
            list.items.append(item)
            modelContext.insert(item)
        }
        try modelContext.save()
    }
}
