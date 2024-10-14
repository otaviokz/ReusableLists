//
//  AddBlueprintView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import SwiftUI
import SwiftData

struct AddBlueprintView: SheetWrappedViewable {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var blueprints: [Blueprint]
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var details: String = ""
    @State private var showAlert = false
    @State var isSheetPresented: Binding<Bool>
    
    init(isSheetPresented: Binding<Bool>) {
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack(spacing: 11) {
            Text("New Blueprint")
                .font(.title3)
                .foregroundStyle(Color.cyan)
                .padding(.top, 24)
            
            Form {
                Section("Name") {
                    TextField("Your new Blueprint's name", text: $name.max(SizeConstraints.name))
                        .font(.title3.weight(.medium))
                        .focused($focusState, equals: .name)
                        .submitLabel(.next)
                        .onSubmit {
                            focusState = .details
                        }
                }
                
                Section("Details") {
                    TextField(
                        "Anything you should keep in mind when using a list generated from this blueprint.",
                        text: $details.max(SizeConstraints.details),
                        axis: .vertical
                    )
                        .font(.title3.weight(.light))
                        .focused($focusState, equals: .details)
                        .lineLimit(3, reservesSpace: true)
                        .onChange(of: details) { _, _ in
                            if details.last == "\n" {
                                details = String(details.dropLast())
                                focusState = nil
                            }
                        }
                        .submitLabel(.done)
                }
            }
            .scrollDisabled(true)
            .frame(height: 256)
            .roundClipped()
            
            Spacer()
            
            buttonsStack
                .padding(.bottom, 8)
        }
        .onAppear {
            focusState = .name
        }
        .alert(isPresented: $showAlert) {
            Alert.genericErrorAlert
        }
    }
}

// MARK: - UI

fileprivate extension AddBlueprintView {
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
        .foregroundStyle(Color.cyan)
    }
    
    var saveButton: some View {
        Button { saveBlueprintAndDismissSheet() } label: { Text("Save") }
            .disabled(isSaveButtonDisabled)
    }
    
    var exitButton: some View {
        Button { dismissSheet() } label: { Text("Exit") }
    }
}

// MARK: - SwiftData

fileprivate extension AddBlueprintView {
    var isUniqueName: Bool {
        blueprints.first { $0.name.trimLowcaseEquals(name) } == nil
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func saveBlueprintAndDismissSheet() {
        let newBlueprint = Blueprint(name: name.trimmingSpaces, details: details.trimmingSpaces)
        modelContext.insert(newBlueprint)
        do {
            try modelContext.save()
            dismissSheet()
        } catch {
            showAlert = true
        }
    }
}

#Preview {
    @Previewable @State var isSheetPresented = true
    NavigationStack {
        AddBlueprintView(isSheetPresented: $isSheetPresented)
    }
}
