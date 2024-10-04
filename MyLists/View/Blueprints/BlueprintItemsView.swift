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
    
    @Query(sort: [SortDescriptor(\ToDoList.name)]) private var lists: [ToDoList]
    
    @State private var alertMessage = Alert.gnericErrorMessage
    @State private var presentAlert = false
    @State private var presentAddItemSheet = false
    
    let blueprint: Blueprint
    
    init(for blueprint: Blueprint) {        
        self.blueprint = blueprint
    }
    
    var body: some View {
        List {
            if !blueprint.details.isEmpty {
                Section("Details:") {
                    Text(blueprint.details).font(.title3)
                        .foregroundStyle(Color.primary)
                }
            }
            
            if !blueprint.items.isEmpty {
                Section("Items:") {
                    ForEach(blueprint.items.sortedByName) { item in
                        BlueprintItemRowView(item: item)
                    }
                    .onDelete(perform: deleteItem)
                }
            }
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(Color.cyan)
        .alert(isPresented: $presentAlert) {
            Alert(Alert.genericErrorTitle, message: alertMessage)
        }
        .sheet(isPresented: $presentAddItemSheet) {
            AddBlueprintItemView(blueprint, isSheetPresented: $presentAddItemSheet)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
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
                    Image.gear.sizedToFit(width: 21, height: 21)
                        .padding(.top, 1.5)
                }
                
                if !listInstanceAlreadyExists(for: blueprint) {
                    Image.todolist.sizedToFit(width: 16, height: 20)
                        .onTapGesture {
                            addListInstance(from: blueprint)
                        }
                }
                
                Image.plus.onTapGesture { presentAddItemSheet = true }
                    .padding(.leading, -4)
            }
            .foregroundStyle(Color.cyan)
            .padding(.trailing, 4)
        }
    }
}

// MARK: - SwiftData

private extension BlueprintItemsView {
    func listInstanceAlreadyExists(for blueprint: Blueprint) -> Bool {
        lists.first { $0.name.trimLowcaseEquals(blueprint.name) } != nil
    }
    
    func addListInstance(from blueprint: Blueprint) {
        alertMessage = Alert.gnericErrorMessage
        do {
            if listInstanceAlreadyExists(for: blueprint) {
                throw ListError.listExistsForBlueprint(named: blueprint.name)
            }
            let list = ToDoList(name: blueprint.name, details: blueprint.details)
            list.items = blueprint.items.asToDoItemList()
            modelContext.insert(list)
            
            try modelContext.save()
        } catch let error as ListError {
            if case ListError.listExistsForBlueprint(named: blueprint.name) = error {
                alertMessage = error.message
            }
            presentAlert = true
        } catch {
            presentAlert = true
        }
    }
    
    func deleteItem(_ indexSet: IndexSet) {
        alertMessage = Alert.gnericErrorMessage
        do {
            guard let index = indexSet.first else { throw ListError.emptyDeleteIndexSet }
            let item: BlueprintItem = blueprint.items.sortedByName[index]
            blueprint.items = blueprint.items.filter { $0 != item }
            modelContext.delete(item)
            try modelContext.save()
        } catch {
            presentAlert = true
        }
    }
}
