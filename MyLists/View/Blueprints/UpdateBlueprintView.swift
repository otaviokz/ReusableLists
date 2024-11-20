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
    @State private var presetAlert = false

    let blueprint: Blueprint

    init(_ blueprint: Blueprint) {
        self.blueprint = blueprint
        self.name = blueprint.name
        self.details = blueprint.details
    }

    var body: some View {
        VStack {
            Form {
                Section("Fields:") {
                    Group {
                        TextField("New name", text: $name.max(DataFieldsSizeLimit.name))
                            .font(.title3)
                            .focused($focusState, equals: .name)
                            .onSubmit { focusState = .details }
                        
                        TextField("New details", text: $details.max(DataFieldsSizeLimit.details), axis: .vertical)
                            .font(.headline.weight(.light))
                            .focused($focusState, equals: .details)
                            .lineLimit(SizeConstraints.detailsFieldLineLimit, reservesSpace: true)
                            .onChange(of: details) { _, _ in
                                if details.last == "\n" {
                                    details = String(details.dropLast()).asInput
                                    focusState = nil
                                }
                            }
                    }
                    .foregroundStyle(Color.primary)
                }
                .font(.subheadline.weight(.medium))
            }
            .scrollDisabled(true)
            .frame(height: Sizes.newEntityFormHeight)
            .onAppear {
                focusState = .name
            }
            .roundClipped()

            Spacer()

            buttonsStack
                .padding(.bottom, Sizes.exitOrSaveBottomPadding)
        }
        .foregroundStyle(Color.cyan)
        .alert(isPresented: $presetAlert) {
            Alert.genericError
        }
        .onAppear {
            name = blueprint.name
            details = blueprint.details
        }
        .padding(.top, Sizes.updateEtityViewTopPadding)
        .navigationTitle("Blueprint update")
    }
}

// MARK: - UI

fileprivate extension UpdateBlueprintView {
    enum Field: Hashable {
        case name
        case details
    }
    
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
        Button { updateBlueprintAndDismiss() } label: { Text("Save") }
            .disabled(isSaveButtonDisabled)
    }

    var exitButton: some View {
        Button { dismiss() } label: { Text("Exit") }
    }
}

// MARK: - SwiftData

fileprivate extension UpdateBlueprintView {
    var isUniqueName: Bool {
        blueprints.first { $0.name.asInputLowercasedEquals(name) } == nil
    }

    var didChangeDetails: Bool {
        details != blueprint.details
    }

    var isSaveButtonDisabled: Bool {
        name.asInput.isEmpty || (!isUniqueName && !didChangeDetails)
    }

    func updateBlueprintAndDismiss() {
        blueprint.name = name
        blueprint.details = details
        do {
            try modelContext.save()
            dismiss()
        } catch {
            logger.error("updateBlueprintAndDismiss: \(error)")
            presetAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        UpdateBlueprintView(Blueprint("Groceries", details: "Try farmers market first"))
    }
}
