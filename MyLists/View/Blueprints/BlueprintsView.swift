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
    
    @State private var presentAlert = false
    @State private var alertMessage: String = Alert.genericErrorMessage
    @State private var presentAddBlueprintSheet = false
    @State private var blueprintToDelete: Blueprint?
    @State var showingDeleteAlert = false

    var body: some View {
        bluePrintsList
        .animation(.linear(duration: 0.25), value: blueprints)
        .toolbar {
            Image.plus.padding(.trailing, 4).onTapGesture { presentAddBlueprintSheet = true }
                .foregroundStyle(Color.cyan)
        }
        .alert(isPresented: $presentAlert) {
            Alert.genericError
        }
        .sheet(isPresented: $presentAddBlueprintSheet) {
            NewListOrBlueprintFormView(
                entity: .blueprint,
                isUniqueName: isUniqueName,
                createEntity: createNewEntity,
                handleSaveError: handleSaveError
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .navigationTitle("Blueprints")
    }
    
    @inlinable static func deleteConfirmationDialog(blueprint: Blueprint, title: String, delete: @escaping (Blueprint) -> Void) -> DeletionConfirmationDialog {
        DeletionConfirmationDialog(bluePrint: blueprint, title: title, titleVisibility: .visible, delete: delete)
    }
}

// MARK: - UI

struct DeletionConfirmationDialog: View {
    @Environment(\.dismiss) private var dismiss
    let bluePrint: Blueprint
    let title: String
    let titleVisibility: Visibility
    let delete: (Blueprint) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.title2)
                .padding(.bottom, 16)
            Button(
                role: .destructive,
                action: { delete(bluePrint) },
                label: { Text("Delete").foregroundStyle(Color.red) }
            )
            Button("Cancel", role: .cancel) { dismiss() }
        }
    }
}

private extension BlueprintsView {
    var bluePrintsList: some View {
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
            .confirmationDialog(
                deleteConfirmationDialogTitle,
                isPresented: $showingDeleteAlert,
                titleVisibility: .visible
            ) {
                Button(
                    role: .destructive,
                    action: {
                        guard let blueprintToDelete = blueprintToDelete else { return }
                        delete(blueprint: blueprintToDelete)
                    },
                    label: { Text("Delete").foregroundStyle(Color.red) }
                )
                Button("Cancel", role: .cancel) { showingDeleteAlert = false }
            }
        }
    }
    
    var deleteConfirmationDialogTitle: Text {
        guard let blueprintToDelete = blueprintToDelete else { return Text("") }
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
            try modelContext.save()
            blueprintToDelete = nil
        } catch {
            logger.error("delete(\(blueprint.name)) \(error)")
            presentAlert = true
        }
    }
}

extension BlueprintsView: NewEntityCreatorProtocol {
    func isUniqueName(name: String) -> Bool {
        blueprints.first { $0.name.asInputLowcaseEquals(name) } == nil
    }
    
    func insertEntity(name: String, details: String) throws {
        modelContext.insert(Blueprint(name, details: details))
        try modelContext.save()
    }
    
    func handleSaveError(error: Error, name: String) {
        logger.error("Error createEntityInstanteAndDismissSheet(): \(error)")
        alertMessage = Alert.genericErrorMessage
        if case ListError.blueprintNameUnavailable = error {
            alertMessage = ListError.blueprintNameUnavailable(name).message
        }
        presentAlert = true
    }
}

#Preview {
    BlueprintsView()
}
