//
//  BlueprintItemsView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import SwiftUI
import SwiftData
import UIKit

struct BlueprintItemsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var tabselection: TabSelection
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\ToDoList.name)]) private var lists: [ToDoList]
    
    @State private var alertMessage = Alert.genericErrorMessage
    @State private var presentAlert = false
    @State private var presentSheet = false
    @State private var sheetType: SheetType = .none
    
    let blueprint: Blueprint
    
    init(for blueprint: Blueprint) {
        self.blueprint = blueprint
    }
    
    var body: some View {
        List {
            if !blueprint.details.isEmpty {
                Section("Blueprint Details:") {
                    BlueprintDetailsRowView(blueprint: blueprint)
                        .listRowBackground(Color.gray.opacity(0.35))
                        .listRowSeparatorTint(.gray, edges: .all)
                }
            }
            
            if !blueprint.items.isEmpty {
                Section("Blueprint Items:") {
                    ForEach(blueprint.items.sortedByPriorityAndName) { item in
                        BlueprintItemRowView(item: item)
                            .listRowBackground(Color.gray.opacity(0.35))
                            .listRowSeparatorTint(.gray, edges: .all)
                            .swipeActions(edge: .leading) {
                                Button("Edit") {
                                    sheetType = .edit(item: item)
                                    presentSheet = true
                                }
                            }
                    }
                    .onDelete(perform: deleteItem)
                }
            }
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(Color.cyan)
        .alert(isPresented: $presentAlert) {
            Alert(title: Alert.genericErrorTitle, message: alertMessage)
        }
        .sheet(isPresented: $presentSheet) {
            switch sheetType {
            case .addItem:
                NewListOrBlueprintItemFormView(
                    .blueprint(entity: blueprint),
                    isSheetPresented: $presentSheet,
                    isUniqueNameInEntity: isUniqueNameInEntity,
                    createAndInsertNewItems: createAndInsertNewItems
                )
            case .edit(let item):
                EditBlueprintItemView(
                    item,
                    blueprint: blueprint,
                    isSheetPresented: $presentSheet) { save($0) }
            case .none: EmptyView().frame(width: 0, height: 0)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .toolbar {
            toobarItem
        }
        .navigationTitle(blueprint.name)
    }
}

// MARK: - Edit Item

extension BlueprintItemsView {
    enum SheetType {
        case edit(item: BlueprintItem)
        case addItem
        case none
    }
}

// MARK: - UI

fileprivate extension BlueprintItemsView {
    var toobarItem: ToolbarItem<(), some View> {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 16) {
                NavigationLink {
                    EditBlueprintView(blueprint)
                } label: {
                    Image.gear.sizedToFitSquare(side: 21)
                        .padding(.top, 1.5)
                }
                
                if !listInstanceAlreadyExists(for: blueprint) {
                    Image.docOnDoc.sizedToFit(width: 18.5)
                        .onTapGesture {
                            addListInstance(from: blueprint)
                        }
                        .padding(.trailing, -3.75)
                }
                
                Image.plus.onTapGesture {
                    sheetType = .addItem
                    presentSheet = true
                }
                .padding(.trailing, 4)
            }
            .foregroundStyle(Color.cyan)
            .padding(.trailing, 4)
        }
    }
}

// MARK: - SwiftData

private extension BlueprintItemsView {
    func listInstanceAlreadyExists(for blueprint: Blueprint) -> Bool {
        lists.first { $0.name.asInputLowcaseEquals(blueprint.name) } != nil
    }
    
    func addListInstance(from blueprint: Blueprint) {
        Task {
            do {
                if listInstanceAlreadyExists(for: blueprint) {
                    throw ListError.listExistsForBlueprint(named: blueprint.name)
                }
                let list = ToDoList(blueprint.name, details: blueprint.details)
                list.items = blueprint.items.asToDoItemList()
                withAnimation(.easeInOut(duration: 0.25)) {
                    dismiss()
                }
                
                try await Task.sleep(nanoseconds: WaitTimes.tabSelection)
                
                withAnimation(.easeInOut(duration: 0.25)) {
                    tabselection.select(tab: 1, shouldPopToRootView: true)
                }
                
                try await Task.sleep(nanoseconds: WaitTimes.dismissSheetAndInsertOrRemove)
                
                try withAnimation(.easeIn(duration: 0.25)) {
                    modelContext.insert(list)
                    blueprint.usageCount += 1
                    try modelContext.save()
                }
                
            } catch {
                logger.error("Error addListInstance(from: \(blueprint.name): \(error.localizedDescription)")
                alertMessage = Alert.genericErrorMessage
                if let error = error as? ListError {
                    alertMessage = error.message
                }
                presentAlert = true
            }
        }
    }
    
    func deleteItem(_ indexSet: IndexSet) {
        alertMessage = Alert.genericErrorMessage
        do {
            guard let index = indexSet.first else { throw ListError.emptyDeleteIndexSet }
            let item: BlueprintItem = blueprint.items.sortedByPriorityAndName[index]
            blueprint.items = blueprint.items.filter { $0 != item }
            modelContext.delete(item)
            try modelContext.save()
        } catch {
            logger.error("Error deleteItem(indexSet \(indexSet)): \(error.localizedDescription)")
            presentAlert = true
        }
    }
    
    func save(_ item: BlueprintItem) {
        do {
            try modelContext.save()
        } catch {
            logger.error("Error saving item: \(error)")
            alertMessage = Alert.genericErrorMessage
            presentAlert = true
        }
    }
}

// MARK: - NewItemCreatorProtocol

extension BlueprintItemsView: NewItemCreatorProtocol {
    func isUniqueNameInEntity(name: String) -> Bool {
        blueprint.items.first { $0.name.asInputLowcaseEquals(name) } == nil
    }
    
    func createAndInsertNewItems(_ newItems: [(name: String, priority: Bool)]) throws {
        for newItem in newItems {
            let item = BlueprintItem(newItem.name, priority: newItem.priority)
            blueprint.items.append(item)
            modelContext.insert(item)
        }
        try modelContext.save()
    }
}

#Preview {
    let blueprint = Blueprint("Chores:", details: "There's no scape from the weekend chores!")
    blueprint.items.append(BlueprintItem("Laundry"))
    blueprint.items.append(BlueprintItem("Dishwashing"))
    return NavigationStack {
        BlueprintItemsView(for: blueprint)
    }
}
