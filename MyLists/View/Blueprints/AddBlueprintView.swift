//
//  AddBlueprintView.swift
//  MyLists
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
                .font(.title2)
                .foregroundStyle(Color.cyan)
                .padding(.top, 24)
            
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
            .autocorrectionDisabled()
            .scrollDisabled(true)
            .frame(height: 250)
            .onAppear {
                focusState = .name
            }
            .roundClipped()
            
            buttonsStack
            
            Spacer()
        }
    }
}

fileprivate extension AddBlueprintView {
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
                try saveBlueprint()
                dismissSheet()
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
        Button { dismissSheet() } label: { Text("Exit") }
            .foregroundStyle(Color.cyan)
    }
}

fileprivate extension AddBlueprintView {
    enum Field: Hashable {
        case name
        case details
    }
    
    var isUniqueName: Bool {
        blueprints.first { $0.name.trimLowcaseEquals(name) } == nil
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func saveBlueprint() throws {
        let newBlueprint = Blueprint(name: name.trimmingSpaces, details: details.trimmingSpaces)
        modelContext.insert(newBlueprint)
        try modelContext.save()
    }
}

#Preview {
    @Previewable @State var isSheetPresented = true
    NavigationStack {
        AddBlueprintView(isSheetPresented: $isSheetPresented)
    }
}
