//
//  AddBlueprintItemView.swift
//  MyLists
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
    let blueprint: Blueprint
    
    init(_ blueprint: Blueprint, isSheetPresented: Binding<Bool>) {
        self.blueprint = blueprint
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("New item for \"\(blueprint.name)\"")
                .font(.title2)
                .foregroundStyle(Color.cyan)
                .padding(.top, 24)
            
            Form {
                Section("Name field") {
                    TextField("Your new item's name", text: $name.max(SizeConstraints.name))
                        .font(.title3)
                        .focused($focusState, equals: .name)
                        .onSubmit {
                            focusState = nil
                        }
                }
            }
            .frame(height: 112)
            .roundClipped()
            
            buttonsStack
            
            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert.genericErrorAlert
        }
        .onAppear {
            focusState = .name
        }
    }
}

// MARK: - UI

private extension AddBlueprintItemView {
    enum Field: Hashable {
        case name
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
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
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
            .navigationTitle("Add")
    }
    .sheet(isPresented: $isSheetPresented) {
        AddBlueprintItemView(Blueprint(name: "Groceries"), isSheetPresented: $isSheetPresented)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
    }
}
