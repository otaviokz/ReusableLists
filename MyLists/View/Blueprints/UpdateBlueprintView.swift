//
//  UpdateBlueprintView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 22/09/2024.
//

import SwiftUI
import SwiftData

struct UpdateBlueprintView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var blueprints: [Blueprint]
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var details: String = ""
    @State private var showAlert = false
    @State private var showDeleteConfirmation = false
    
    let blueprint: Blueprint
    
    init(_ blueprint: Blueprint) {
        self.blueprint = blueprint
        self.name = blueprint.name
        self.details = blueprint.details
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Form {
                Section("Name") {
                    TextField("New name", text: $name.max(SizeConstraints.name))
                        .font(.title3.weight(.medium))
                        .focused($focusState, equals: .name)
                        .onSubmit {
                            focusState = .details
                        }
                }
                Section("Details") {
                    TextField("New details", text: $details.max(SizeConstraints.details), axis: .vertical)
                        .font(.title3.weight(.light))
                        .focused($focusState, equals: .details)
                        .lineLimit(4, reservesSpace: true)
                        .onChange(of: details) { _, _ in
                            if details.last == "\n" {
                                details = String(details.dropLast()).trimmingSpaces
                                focusState = nil
                            }
                        }
                }
            }
            .autocorrectionDisabled()
            .scrollDisabled(true)
            .frame(height: 282)
            .onAppear {
                focusState = .name
            }
            .roundClipped()
            
            buttonsStack
            
            Spacer()
        }
        .actionSheet(isPresented: $showDeleteConfirmation) {
            ActionSheet(
                title: Text("Are you sure you want to delete \"\(blueprint.name)\" and all its items"),
                message: nil,
                buttons: [
                    .cancel(Text("No")) { showDeleteConfirmation = false},
                    .destructive(Text("Yes")) {
                        do {
                            try deleteBlueprint()
                            dismiss()
                        } catch {
                            showAlert = true
                        }
                    }
                ]
            )
        }
        .onAppear {
            name = blueprint.name
            details = blueprint.details
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image.trash
                    .foregroundStyle(Color.red)
                    .onTapGesture {
                        showDeleteConfirmation = true
                    }
            }
        }
        .navigationTitle("Edit \"\(blueprint.name)\"")
    }
}

fileprivate extension UpdateBlueprintView {
    var buttonsStack: some View {
        HStack {
            Spacer()
            exitButton
            Spacer()
            if !isSaveButtonDisabled {
                saveButton
                Spacer()
            }
        }
        .font(.title2)
    }
    
    var saveButton: some View {
        Button {
            do {
                try updateBlueprint()
                dismiss()
            } catch {
                showAlert = true
            }
        } label: {
            Text("Save")
        }
        .foregroundStyle(Color.cyan.opacity(isSaveButtonDisabled ? 0 : 1))
        .disabled(isSaveButtonDisabled)
        .alert(isPresented: $showAlert) {
            Alert.genericErrorAlert
        }
    }
    
    var exitButton: some View {
        Button { dismiss() } label: { Text("Exit") }
            .foregroundStyle(Color.cyan)
    }
}

// MARK: - CoreData
fileprivate extension UpdateBlueprintView {
    var isUniqueName: Bool {
        blueprints.first { $0.name.trimLowcaseEquals(name) } == nil
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func updateBlueprint() throws {
        blueprint.name = name
        blueprint.details = details
        try modelContext.save()
    }
    
    func deleteBlueprint() throws {
        modelContext.delete(blueprint)
        try modelContext.save()
    }
}

// MARK: - Focus
extension UpdateBlueprintView {
    enum Field: Hashable {
        case name
        case details
    }
}

#Preview {
    NavigationStack {
        UpdateToDoListView(ToDoList(name: "Groceries", details: "Try farmers market first"))
    }
}
