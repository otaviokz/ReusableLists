//
//  AddBlueprintItemView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import SwiftUI

struct AddBlueprintItemView: SheetWrappedViewable {
    @Environment(\.modelContext) private var modelContext
   
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var showAlert = false
    @State var isSheetPresented: Binding<Bool>
    @State var invalidNameSent = false
    
    let blueprint: Blueprint
    
    init(_ blueprint: Blueprint, isSheetPresented: Binding<Bool>) {
        self.blueprint = blueprint
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image.blueprint
                Text("Blueprint: \"\(blueprint.name)\"")
                    .font(.title3)
            }
            .padding(.top, 24)
            
            Form {
                Section("Fields:") {
                    TextField("New item's name", text: $name.max(SizeConstraints.name))
                        .font(.title3)
                        .foregroundStyle(Color.primary)
                        .focused($focusState, equals: .name)
                        .onChange(of: name) { invalidNameSent = false }
                        .submitLabel(.send)
                        .onSubmit {
                            invalidNameSent = isSaveButtonDisabled
                            if !isSaveButtonDisabled {
                                saveBlueprintItemAndDismissSheet()
                            }
                        }
                }
                .font(.subheadline.weight(.medium))
            }
            .frame(height: Sizes.newItemFormHeight)
            .roundClipped()
            
            if showNameUnavailableMessage {
                nameNotAvailableMessage
            }
            
            Spacer()
            
            buttonsStack
                .padding(.bottom, 8)
        }
        .foregroundStyle(Color.cyan)
        .alert(isPresented: $showAlert) {
            Alert.genericError
        }
        .task {
            focusState = .name
        }
    }
}

// MARK: - UI

private extension AddBlueprintItemView {
    enum Field: Hashable {
        case name
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    var showNameUnavailableMessage: Bool {
        invalidNameSent && isSaveButtonDisabled
    }
    
    var nameNotAvailableMessage: some View {
            Text("⚠ An item named \"\(name)\" already exists for this Blueprint.")
                .font(.headline.weight(.light))
                .foregroundStyle(Color.red)
                .frame(alignment: .leading)
                .padding(.top, -6)
                .padding(.horizontal, 16)
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
        Button { saveBlueprintItemAndDismissSheet() } label: { Text("Save") }
            .disabled(isSaveButtonDisabled)
    }
    
    var exitButton: some View {
        Button { dismissSheet() } label: { Text("Exit") }
    }
}

// MARK: - SwiftData

fileprivate extension AddBlueprintItemView {
    var isUniqueName: Bool {
        blueprint.items.first { $0.name == name } == nil
    }
    
    func saveBlueprintItemAndDismissSheet() {
        let item = BlueprintItem(name: name.trimmingSpaces)
        modelContext.insert(item)
        blueprint.items.append(item)
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
        VStack { }
            .navigationTitle("Groceries")
    }
    .sheet(isPresented: $isSheetPresented) {
        AddBlueprintItemView(Blueprint(name: "Groceries"), isSheetPresented: $isSheetPresented)
    }
}
