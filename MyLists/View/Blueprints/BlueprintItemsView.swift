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
    @State private var presentAddItemSheet = false
    
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
                    ForEach(blueprint.items.sortedByName) { item in
                        BlueprintItemRowView(item: item)
                            .listRowBackground(Color.gray.opacity(0.35))
                            .listRowSeparatorTint(.gray, edges: .all)
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
        .sheet(isPresented: $presentAddItemSheet) {
            NewListOrBlueprintItemFormView(
                .blueprint(entity: blueprint),
                isSheetPresented: $presentAddItemSheet,
                isUniqueNameInEntity: isUniqueNameInEntity,
                createAndInsertNewItems: createAndInsertNewItems
            )
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .toolbar {
            toobarItem
        }
        .navigationTitle(blueprint.name)
    }
}

// MARK: - UI

fileprivate extension BlueprintItemsView {
    var toobarItem: ToolbarItem<(), some View> {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 16) {
                NavigationLink {
                    UpdateBlueprintView(blueprint)
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
                
                Image.plus.onTapGesture { presentAddItemSheet = true }
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
        lists.first { $0.name.asInputLowercasedEquals(blueprint.name) } != nil
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
                
                try await Task.sleep(nanoseconds: WaitTimes.sheetDismissAndInsertOrRemove)
                
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
            let item: BlueprintItem = blueprint.items.sortedByName[index]
            blueprint.items = blueprint.items.filter { $0 != item }
            modelContext.delete(item)
            try modelContext.save()
        } catch {
            logger.error("Error deleteItem(indexSet \(indexSet)): \(error.localizedDescription)")
            presentAlert = true
        }
    }
}

extension BlueprintItemsView: NewItemCreatorProtocol {
    func isUniqueNameInEntity(name: String) -> Bool {
        blueprint.items.first { $0.name.asInputLowercasedEquals(name) } == nil
    }
    
    func createAndInsertNewItems(names: [String]) throws {
        for name in names {
            let item = BlueprintItem(name)
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
