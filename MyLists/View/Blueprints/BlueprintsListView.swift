//
//  BlueprintsView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import SwiftUI
import SwiftData

struct BlueprintsListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: [SortDescriptor(\Blueprint.name, order: .forward)]) private var blueprints: [Blueprint]
    @Query private var toDoLists: [ToDoList]
    @State private var showAddBlueprintSheet = false
    @State private var showErrorAlert = false

    var body: some View {
        List {
            ForEach(blueprints) { blueprint in
                NavigationLink(destination: BlueprintItemsListView(blueprint)) {
                    BlueprintRowView(blueprint: blueprint)
                }
            }
            .onDelete(perform: deleteBlueprint)
        }
        .alert(isPresented: $showErrorAlert) {
            Alert.genericErrorAlert
        }
        .toolbar {
            Image.plus
                .foregroundStyle(Color.cyan)
                .padding(.trailing, 4)
                .onTapGesture {
                    showAddBlueprintSheet = true
                }
        }
        .sheet(isPresented: $showAddBlueprintSheet) {
            NewListOrBlueprintView(isSheetPresented: $showAddBlueprintSheet, entity: .blueprint)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .navigationTitle("Blueprints")
    }
}

// MARK: - SwiftData

private extension BlueprintsListView {
    func deleteBlueprint(_ indexSet: IndexSet) {
        do {
            guard let index = indexSet.first else { throw ListError.deleteEntityIndexNotFound }
            let blueprint = blueprints[index]
            modelContext.delete(blueprint)
            try modelContext.save()
        } catch {
            showErrorAlert = true
        }
    }
}


#Preview {
    BlueprintsListView()
}
