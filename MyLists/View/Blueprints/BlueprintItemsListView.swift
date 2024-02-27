//
//  BlueprintItemsView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import SwiftUI
import SwiftData

struct BlueprintItemsListView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.presentationMode) var presentationMode
    var blueprint: Blueprint
    let toDoLists: [ToDoList]
    @State var showAlert = false
    @State var alertMessage = ""
    
    init(_ bluePrint: Blueprint, todoLists: [ToDoList]) {
        self.blueprint = bluePrint
        self.toDoLists = todoLists
    }
    
    var body: some View {
        List {
            if !blueprint.details.isEmpty {
                Section("Details") {
                    Text(blueprint.details)
                }
            }
            
            Section("Blueprints") {
                ForEach(blueprint.items.azSorted()) { item in
                    BlueprintItemRowView(item: item)
                }
                .onDelete(perform: { indexSet in
                    delete(indexSet)
                })
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { showAlert = false }
        }
        .navigationTitle("\u{270E}  \(blueprint.name)")
        .toolbar {
            HStack {
                Button("Add to ToDoLists", systemImage: "doc.on.doc") {
                    do {
                        try DataConnector(lists: toDoLists, modelContext: modelContext)
                            .createInstance(of: blueprint)
                        presentationMode.wrappedValue.dismiss()
                        
                    } catch {
                        alertMessage = ListError.listNameUnavailable(blueprint.name).message
                        showAlert = true
                    }
                }
                
                NavigationLink(destination: {
                    AddBluePrintItemView(blueprint)
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        if let first = indexSet.first {
            let item = blueprint.items.azSorted()[first]
            guard let translatedIndex = blueprint.items.firstIndex(of: item) else {
                fatalError("Item not found in Blueprint (\(blueprint.name))")
            }
            blueprint.items.remove(at: translatedIndex)
        }
    }
}


