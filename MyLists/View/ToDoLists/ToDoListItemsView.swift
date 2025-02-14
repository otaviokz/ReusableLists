//
//  ItemsView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData
import PDFKit
import TPPDF
import Foundation

struct ToDoListItemsView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject private var tabselection: TabSelection
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\Blueprint.name)]) private var blueprints: [Blueprint]
        
    @State var alertMessage = Alert.genericErrorMessage
    @ObservedObject private var sheetPresenter = SheetPresenter()
    // Necessary for some reason, the guy above doesn't do the trick
    @State private var presentDeleteListsSheet = false
    @State private var sortType: SortType = .doneLast
    
    
    let list: ToDoList
    let allDoneAction: (ToDoList) -> Void
    
    init(for list: ToDoList, allDoneAction: @escaping (ToDoList) -> Void) {
        self.list = list
        self.allDoneAction = allDoneAction
    }
    
    var body: some View {
        VStack {
            if !list.items.sorted(by: sortType).isEmpty {
                GaugeAndPriorityListHeaderView(list: list)
            }
            
            listView
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.cyan)
                .actionSheet(isPresented: $presentDeleteListsSheet) {
                    deleteListOptionActionSheet
                }
                .sheet(isPresented: $sheetPresenter.presentSheet) {
                    switch sheetPresenter.sheetType {
                    case .sortItems: SortTypeView(current: sortType) { sortType = $0 }
                    case .addItem: buildNewItemItemFromView()
                    case .edit(let item): EditItemFormView(item, list: list) { save($0) }
                    }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .alert(isPresented: $sheetPresenter.presentAlert) {
            Alert(title: Alert.genericErrorTitle, message: alertMessage)
        }
        .toolbar {
            toolBarView
        }
        .onAppear {
            checkPopToRootView()
        }
        .onChange(of: list.items) {
            list.items = list.items
                .sorted(by: sortType)
                .sortedByPriorityAndNameKeepingDoneOrder
        }
        .navigationTitle(list.name)
    }
}

// MARK: - Private Methods

private extension ToDoListItemsView {
    func buildNewItemItemFromView() -> NewListOrBlueprintItemFormView {
        NewListOrBlueprintItemFormView(
            .toDoList(entity: list),
            isUniqueNameInEntity: isUniqueNameInEntity,
            createAndInsertNewItems: createAndInsertNewItems
        )
    }
    
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

class SheetPresenter: ObservableObject {
    @Published var sheetType: SheetType = .addItem
    @Published var presentSheet = false
    
    func presentAddNewItemSheet() {
        self.sheetType = .addItem
        presentSheet = true
    }
    
    func presentEditItemSheet(_ item: ToDoItem) {
        self.sheetType = .edit(item: item)
        presentSheet = true
    }
}
    
enum SheetType {
    case edit(item: ToDoItem)
    case addItem
}

// MARK: - UI 1

private extension ToDoListItemsView {
    var listView: some View {
        List {
            if !list.details.isEmpty {
                Section("List Details:") {
                    if !list.details.isEmpty {
                        Text(list.details).font(.title3)
                            .foregroundStyle(Color.primary)
                    }
                }
            }
            
            if !list.items.isEmpty {
                Section("List items") {
                    ForEach(list.items.sorted(by: sortType).sortedByPriorityAndNameKeepingDoneOrder) { item in
                        ToDoListItemRowView(item: item) {
                            save(item)
                            if list.items.doneItems.count == list.items.count {
                                presentDeleteListsSheet = true
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button("Edit", role: .cancel) {
                                sheetPresenter.presentEditItemSheet(item)
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
        }
    }
}

// MARK: - UI2

extension ToDoListItemsView {
    var deleteListOptionActionSheet: ActionSheet {
        ActionSheet(
            title: Text("List completed!"),
            message: Text("Would you like to delete it now it's completed?"),
            buttons: [ActionSheet.Button.destructive(Text("Yes")) {
                dismiss()
                allDoneAction(list)
                presentDeleteListsSheet = false
            },
            .cancel(Text("Cancel"))]
        )
    }
    
    var shareMessage: URL {
        let document = PDFDocument(format: PDFPageFormat.a4)
        let attributedTitle = NSMutableAttributedString(string: list.name, attributes: [
            .font: UIFont.systemFont(ofSize: 24.0),
            .foregroundColor: UIColor.systemBlue
        ])
        document.add(attributedTextObject: PDFAttributedText(text: attributedTitle))
        
        if !list.details.isEmpty {
            let attributedDetails = NSMutableAttributedString(string: "\nDetails: \(list.details)", attributes: [
                .font: UIFont.systemFont(ofSize: 20.0),
                .foregroundColor: UIColor.systemBlue
            ])
            document.add(attributedTextObject: PDFAttributedText(text: attributedDetails))
        }
         
        let attributedSpacing = NSMutableAttributedString(string: "\n", attributes: [
            .font: UIFont.systemFont(ofSize: 20.0),
            .foregroundColor: UIColor.cyan
        ])
        document.add(attributedTextObject: PDFAttributedText(text: attributedSpacing))
        
        for item in list.items.sorted(by: sortType) {
            let attributedItem = NSMutableAttributedString(string: " ▢  -  \(item.name)\n", attributes: [
                .font: UIFont.systemFont(ofSize: 16.0),
                .foregroundColor: UIColor.black
            ])
            document.add(attributedTextObject: PDFAttributedText(text: attributedItem))
        }
            
        let attributedAppName = NSMutableAttributedString(string: "\nReusable Lists\n", attributes: [
            .font: UIFont.systemFont(ofSize: 22.0),
            .foregroundColor: UIColor.cyan
        ])
        document.add(attributedTextObject: PDFAttributedText(text: attributedAppName))
        let generator = PDFGenerator(document: document)
        let url  = try! generator.generateURL(filename: "Example.pdf")
        return url
    }
    
    func presentDeleteOptionIfCompleted() {
        if list.completion >= 1 { presentDeleteListsSheet = true }
    }
    
    var toolBarView: some View {
        HStack(spacing: 16) {
            ShareLink(item: shareMessage) { Label("", systemImage: "square.and.arrow.up") }
                .padding(.trailing, -8)
                .padding(.top, -4)
            
            NavigationLink { EditToDoListFormView(list) } label: { Image.edit.sizedToFit(width: 21, height: 21).padding(.top, 1.5) }
            
            if list.items.count > 1 {
                Image.sort.sizedToFit(height: 18).onTapGesture {
                    sheetPresenter.presentSortSheet()
                }
            }
            
            Image.plus.onTapGesture { sheetPresenter.presentAddNewItemSheet() }.padding(.leading, -4)
        }
        .foregroundStyle(Color.cyan)
        .padding(.trailing, 4)
    }
}

// MARK: - Sheets
extension ToDoListItemsView {
    class SheetPresenter: ObservableObject {
        @Published var sheetType: ToDoListItemsView.SheetType = .addItem
        @Published var presentSheet = false
        @Published var presentAlert = false
        
        func presentAddNewItemSheet() {
            self.sheetType = .addItem
            presentSheet = true
        }
        
        func presentEditItemSheet(_ item: ToDoItem) {
            self.sheetType = .edit(item: item)
            presentSheet = true
        }
        
        func presentSortSheet() {
            self.sheetType = .sortItems
            presentSheet = true
        }
        
        func presentMessageAlert() {
            presentAlert = true
        }
    }
    
    enum SheetType {
        case edit(item: ToDoItem)
        case addItem
        case sortItems
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
            sheetPresenter.presentMessageAlert()
        }
    }
    
    func save(_ item: ToDoItem) {
        do {
            try modelContext.save()
        } catch {
            logger.error("Error editing item: \(error)")
            alertMessage = Alert.genericErrorMessage
            sheetPresenter.presentMessageAlert()
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
