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
    @State var showInstanceAlert = false
    @State var showAddItemSheet = false
    let blueprint: Blueprint
    
    init(_ bluePrint: Blueprint) {
        self.blueprint = bluePrint
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
            Alert.genericErrorAlert
        }
        .alert(isPresented: $showInstanceAlert) {
            Alert(Alert.defaultErrorTitle, message: "A ToDoList called \(blueprint.name) already exists.")
        }
        .sheet(isPresented: $showAddItemSheet) {
            AddBluePrintItemView(blueprint, isSheetPresented: $showAddItemSheet)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .navigationTitle("\u{270E}  \(blueprint.name)")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    NavigationLink {
                        UpdateBlueprintView(blueprint)
                    } label: {
                        Images.gear.sizedToFit()
                    }
                    
                    if !listExistsFor(blueprint) {
                        Images.docOnDoc
                            .sizedToFit(width: 21.5, height: 21.5)
                            .onTapGesture {
                                addInstance()
                            }
                    }
                    
                    Images.plus
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
    func listExistsFor(_ blueprint: Blueprint) -> Bool {
        lists.first { $0.name == blueprint.name} != nil
    }
    
    func instanceExistsFor(_ blueprint: Blueprint) -> Bool {
        !blueprint.items.filter { $0.name.trimmingSpacesLowercasedEquals(blueprint.name) }.isEmpty
    }
    
    func createInstance(of blueprint: Blueprint) throws {
        if instanceExistsFor(blueprint) {
            throw ListError.listNameUnavailable(blueprint.name)
        }
        
        let list = ToDoList(name: blueprint.name, details: blueprint.details)
        list.items = blueprint.items.asToDoItemList()
        modelContext.insert(list)
        
        try modelContext.save()
    }
        
    func delete(_ indexSet: IndexSet) throws  {
        if let first = indexSet.first {
            let item = blueprint.items.sortedByName[first]
            guard let translatedIndex = blueprint.items.firstIndex(of: item) else {
                throw ListError.bluePrintItemNotFound
            }
            
            blueprint.items.remove(at: translatedIndex)
            try modelContext.save()
        }
    }
    
    func addInstance() {        
        let list = ToDoList(name: blueprint.name, details: blueprint.details)
        list.items = blueprint.items.asToDoItemList()
        modelContext.insert(list)
        do {
            try modelContext.save()
        } catch {
            showAlert = true
        }
    }
}
