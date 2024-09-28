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
                        .lineLimit(3, reservesSpace: true)
                        .onChange(of: details) { _, _ in
                            if details.last == "\n" {
                                details = String(details.dropLast()).trimmingSpaces
                                focusState = nil
                            }
                        }
                }
            }
            .scrollDisabled(true)
            .frame(height: 282)
            .onAppear {
                focusState = .name
            }
            .roundClipped()
            
            buttonsStack
            
            Spacer()
        }
        .onAppear {
            name = blueprint.name
            details = blueprint.details
        }
        .alert(isPresented: $showAlert) {
            Alert.genericErrorAlert
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
        .foregroundStyle(Color.cyan)
    }
    
    var saveButton: some View {
        Button {
            updateBlueprint()
            dismiss()
        } label: {
            Text("Save")
        }
        .disabled(isSaveButtonDisabled)
    }
    
    var exitButton: some View {
        Button { dismiss() } label: { Text("Exit") }
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
    
    func updateBlueprint() {
        blueprint.name = name
        blueprint.details = details
        do {
            try modelContext.save()
        } catch {
            showAlert = true
        }
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
