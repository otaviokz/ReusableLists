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
//    @State var showConfirmationSheet = false
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
                .onDelete(perform: deleteBlueprintItem)
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
//        .actionSheet(isPresented: $showConfirmationSheet) {
//            ActionSheet(
//                title: Text("Are you sure you want to delete \"\(blueprint.name)\" and all its itens?"),
//                message: nil,
//                buttons: [
//                    .cancel(Text("Cancel")) { },
//                    .destructive(Text("Yes")) {
//                        do {
//                            try delete(blueprint: blueprint)
//                            dismiss()
//                        } catch {
//                            showAlert = true
//                        }
//                    }
//                ]
//            )
//        }
        .navigationTitle("\u{270E}  \(blueprint.name)")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
//                    Image.trash.sizedToFit()
//                        .foregroundStyle(Color.red)
//                        .onTapGesture {
//                            showConfirmationSheet = true
//                        }
//                        .padding(.trailing, -8)
                    
                    NavigationLink {
                        UpdateBlueprintView(blueprint)
                    } label: {
                        Image.gear.sizedToFit()
                    }
                    
                    if !listInstanceAlreadyExists(for: blueprint) {
                        Image.docOnDoc
                            .sizedToFit(width: 21.5, height: 21.5)
                            .onTapGesture {
                                createListInstance(of: blueprint)
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
    
    func listInstanceAlreadyExists(for blueprint: Blueprint) -> Bool {
        lists.first { $0.name.trimLowcaseEquals(blueprint.name) } != nil
    }
    
    func createListInstance(of blueprint: Blueprint) {
        alertMessage = Alert.defaultErrorMessage
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
            showAlert = true
        } catch {
            showAlert = true
        }
    }
        
    func deleteBlueprintItem(_ indexSet: IndexSet)  {
        alertMessage = Alert.defaultErrorMessage
        do {
            guard let index = indexSet.first else { throw ListError.deleteEntityIndexNotFound }
            let item: BlueprintItem = blueprint.items[index]
            blueprint.items = blueprint.items.filter { $0 != item }
            modelContext.delete(item)
            try modelContext.save()
        } catch {
            showAlert = true
        }
    }
}
