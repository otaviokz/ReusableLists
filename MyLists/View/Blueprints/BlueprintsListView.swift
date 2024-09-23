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
    @State private var showAddBlueprint = false

    var body: some View {
        List {
            ForEach(blueprints) { blueprint in
                NavigationLink(destination: BlueprintItemsListView(blueprint)) {
                    BlueprintRowView(blueprint: blueprint)
                }
            }
            .onDelete(perform: deleteBlueprints)
        }
        .toolbar {
            Images.plus
                .foregroundStyle(Color.cyan)
                .padding(.trailing, 4)
                .onTapGesture {
                    showAddBlueprint = true
                }
        }
        .sheet(isPresented: $showAddBlueprint) {
            AddBlueprintView(isSheetPresented: $showAddBlueprint)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .navigationTitle("Blueprints")
    }
}

private extension BlueprintsListView {
    func deleteBlueprints(_ indexSet: IndexSet) {
        for index in indexSet {
            let blueprint = blueprints[index]
            modelContext.delete(blueprint)
        }
    }
}

#Preview {
    BlueprintsListView()
}
