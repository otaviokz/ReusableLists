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
    
    @Query(sort: [SortDescriptor(\Blueprint.name)]) private var blueprints: [Blueprint]
    @Query private var toDoLists: [ToDoList]
    
    var body: some View {
        List {
            ForEach(blueprints) { blueprint in
                NavigationLink(destination: BlueprintItemsListView(blueprint, todoLists: toDoLists)) {
                    BlueprintRowView(blueprint: blueprint)
                }
            }
            .onDelete(perform: deleteBlueprints)
        }
        .toolbar {
            NavigationLink(destination: {
                NewBlueprintView()
            }, label: {
                Button("Add blueprint", systemImage: "plus") {}
            })
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
