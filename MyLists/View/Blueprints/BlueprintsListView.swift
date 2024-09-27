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
    
    @Query(sort: [SortDescriptor(\Blueprint.name, order: .forward)]) private var Blueprints: [Blueprint]
    @Query private var toDoLists: [ToDoList]
    @State private var showAddBlueprint = false

    var body: some View {
        List {
            ForEach(Blueprints) { blueprint in
                NavigationLink(destination: BlueprintItemsListView(blueprint)) {
                    BlueprintRowView(blueprint: blueprint)
                }
            }
        }
        .toolbar {
            Image.plus
                .foregroundStyle(Color.cyan)
                .padding(.trailing, 4)
                .onTapGesture {
                    showAddBlueprint = true
                }
        }
        .sheet(isPresented: $showAddBlueprint) {
            NewListOrBlueprintView(
                isSheetPresented: $showAddBlueprint,
                entity: .blueprint
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .navigationTitle("Blueprints")
    }
}

#Preview {
    BlueprintsListView()
}
