//
//  BlueprintsView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import SwiftUI
import SwiftData

struct BlueprintsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: [SortDescriptor(\Blueprint.name, order: .forward)]) private var blueprints: [Blueprint]
    
    @State private var presentErrorAlert = false
    @State private var presentAddBlueprintSheet = false
    @State private var blueprintToDelete = Blueprint.placeholderBlueprint
    @State var showingDeleteAlert = false

    var body: some View {
        List {
            ForEach(blueprints) { blueprint in
                NavigationLink(destination: BlueprintItemsView(for: blueprint)) {
                    BlueprintRowView(blueprint)
                }
                .swipeActions {
                    Button("Delete", role: .cancel) {
                        blueprintToDelete = blueprint
                        showingDeleteAlert = true
                    }
                    .tint(.red)
                }
                .listRowBackground(Color.gray.opacity(0.4))
                .listRowSeparatorTint(.gray, edges: .all)
            }
            .confirmationDialog(deleteConfirmationText, isPresented: $showingDeleteAlert, titleVisibility: .visible) {
                Button(
                    role: .destructive,
                    action: {
                        delete(blueprint: blueprintToDelete)
                    },
                    label: { Text("Delete").foregroundStyle(Color.red) }
                )
                Button("Cancel", role: .cancel) { showingDeleteAlert = false }
            }
        }
        .toolbar {
            Image.plus.padding(.trailing, 4).onTapGesture { presentAddBlueprintSheet = true }
                .foregroundStyle(Color.cyan)
        }
        .alert(isPresented: $presentErrorAlert) {
            Alert.genericError
        }
        .sheet(isPresented: $presentAddBlueprintSheet) {
            AddListOrBlueprintView(isSheetPresented: $presentAddBlueprintSheet, entity: .blueprint)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .navigationTitle("Blueprints")
    }
}

// MARK: - UI

private extension BlueprintsView {
    var deleteConfirmationText: Text {
        var message = "Blueprint \"\(blueprintToDelete.name)\""
        if !blueprintToDelete.items.isEmpty {
            message += " and it's \(blueprintToDelete.items.count) items"
        }
        message += " will be deleted."
        return Text(message)
    }
}

// MARK: - SwiftData

private extension BlueprintsView {
    func delete(blueprint: Blueprint) {
        do {
            modelContext.delete(blueprint)
            blueprintToDelete = .placeholderBlueprint
            try modelContext.save()
        } catch {
            logger.error("delete(\(blueprint.name)) \(error)")
            presentErrorAlert = true
        }
    }
}

#Preview {
    BlueprintsView()
}
