//
//  BlueprintItemsView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import SwiftUI
import SwiftData
import UIKit

struct BlueprintItemsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\ToDoList.name)]) private var lists: [ToDoList]
    @Environment(\.dismiss) var dismiss
    @State var showAlert = false
    @State var alertMessage = Alert.defaultErrorMessage
    @State var showInstanceAlert = false
    @State var showAddItemSheet = false
    @State var showConfirmationSheet = false
    let blueprint: Blueprint
    
    init(_ blueprint: Blueprint) {
        self.blueprint = blueprint
    }
    
    var body: some View {
        List {
            if !blueprint.details.isEmpty {
                Section("Details") {
                    Text(blueprint.details)
                        .font(.title3)
                }
            }
            
            Section("Blueprints") {
                ForEach(blueprint.items.sortedByName) { item in
                    BlueprintItemRowView(item: item)
                }
                .onDelete(perform: { indexSet in
                    do {
                       try delete(indexSet)
                    } catch {
                        showAlert = true
                    }
                })
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(Alert.defaultErrorTitle, message: alertMessage)
        }
        .alert(isPresented: $showInstanceAlert) {
            Alert(Alert.defaultErrorTitle, message: "A ToDoList called \(blueprint.name) already exists.")
        }
        .sheet(isPresented: $showAddItemSheet) {
            AddBlueprintItemView(blueprint, isSheetPresented: $showAddItemSheet)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .actionSheet(isPresented: $showConfirmationSheet) {
            ActionSheet(
                title: Text("Are you sure you want to delete \"\(blueprint.name)\" and all its itens?"),
                message: nil,
                buttons: [
                    .cancel(Text("Cancel")) { },
                    .destructive(Text("Yes")) {
                        do {
                            try delete(blueprint: blueprint)
                            dismiss()
                        } catch {
                            showAlert = true
                        }
                    }
                ]
            )
        }
        .navigationTitle("\u{270E}  \(blueprint.name)")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Image.trash.sizedToFit()
                        .foregroundStyle(Color.red)
                        .onTapGesture {
                            showConfirmationSheet = true
                        }
                        .padding(.trailing, -8)
                    
                    NavigationLink {
                        UpdateBlueprintView(blueprint)
                    } label: {
                        Image.gear.sizedToFit()
                    }
                    
                    if !listExistsFor(blueprint) {
                        Image.docOnDoc
                            .sizedToFit(width: 21.5, height: 21.5)
                            .onTapGesture {
                                alertMessage = Alert.defaultErrorMessage
                                do {
                                    try createInstance(of: blueprint)
                                } catch let error as ListError {
                                    if case .listExistsForBlueprinte(named: blueprint.name) = error {
                                        alertMessage = error.message
                                    }
                                    showAlert = true
                                } catch {
                                    showAlert = true
                                }
                            }
                    }
                    
                    Image.plus
                        .onTapGesture {
                            showAddItemSheet = true
                        }
                }
                .foregroundStyle(Color.cyan)
                .padding(.trailing, 4)
            }
            
        }
    }
}

private extension BlueprintItemsListView {
    func delete(blueprint: Blueprint) throws {
        modelContext.delete(blueprint)
        try modelContext.save()
    }
    
    func listExistsFor(_ Blueprint: Blueprint) -> Bool {
        lists.first { $0.name == Blueprint.name} != nil
    }
    
    func instanceExistsFor(_ blueprint: Blueprint) -> Bool {
        lists.first { $0.name.trimLowcaseEquals(blueprint.name) } != nil
    }
    
    func createInstance(of Blueprint: Blueprint) throws {
        if instanceExistsFor(Blueprint) {
            throw ListError.listExistsForBlueprinte(named: Blueprint.name)
        }
        
        let list = ToDoList(name: Blueprint.name, details: Blueprint.details)
        list.items = Blueprint.items.asToDoItemList()
        modelContext.insert(list)
        
        try modelContext.save()
    }
        
    func delete(_ indexSet: IndexSet) throws  {
        guard let index = indexSet.first else { throw ListError.unknown(error: nil) }
        let item: BlueprintItem = blueprint.items[index]
        blueprint.items = blueprint.items.filter { $0 != item }
        modelContext.delete(item)
        try modelContext.save()
    }
}
