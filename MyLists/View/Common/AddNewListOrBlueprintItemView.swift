//
//  NewEntityItem.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 18/10/2024.
//

import SwiftUI

struct AddNewListOrBlueprintItemView: View, SheetWrappedViewable {
    @Environment(\.modelContext) private var modelContext
    
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var invalidNameSent = false
    @State private var presentAlert = false
    @State var isSheetPresented: Binding<Bool>
    
    let newItemForEntity: NewItemForEntity
    
    init(_ newItemForEntity: NewItemForEntity, isSheetPresented: Binding<Bool>) {
        self.newItemForEntity = newItemForEntity
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                newItemForEntity.image
                Text(headerTitle)
                    .font(.title3)
            }
            .padding(.top, 24)
            
            Form {
                Section("Fields:") {
                    TextField("New item's name", text: $name.max(DataFieldsSizeLimit.name))
                        .font(.title3)
                        .foregroundStyle(Color.primary)
                        .focused($focusState, equals: .name)
                        .onChange(of: name) { invalidNameSent = false }
                        .submitLabel(.send)
                        .onSubmit {
                             invalidNameSent = isSaveButtonDisabled
                             if !isSaveButtonDisabled {
                                saveNewItemAdnDismissSheet()
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
        .foregroundColor(Color.cyan)
        .alert(isPresented: $presentAlert) {
            Alert.genericError
        }
        .onAppear {
            focusState = .name
        }
    }
}

// MARK: - UI

private extension AddNewListOrBlueprintItemView {
    enum Field: Hashable {
        case name
    }
    
    var headerTitle: String {
        switch newItemForEntity {
            case .toDoList(let list): "List: \"\(list.name)\""
            case .blueprint(let blueprint): "Blueprint: \"\(blueprint.name)\""
        }
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    var showNameUnavailableMessage: Bool {
        invalidNameSent && isSaveButtonDisabled
    }
    
    var nameNotAvailableMessage: some View {
        let text = switch newItemForEntity {
            case .toDoList:
                Text("⚠ An item named \"\(name)\" already exists for this List.")
            case .blueprint:
                Text("⚠ An item named \"\(name)\" already exists for this Blueprint.")
        }
        
        return text
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
        Button { saveNewItemAdnDismissSheet() } label: { Text("Save") }
            .disabled(isSaveButtonDisabled)
    }
    
    var exitButton: some View {
        Button { dismissSheet() } label: { Text("Exit") }
    }
}

// MARK: - SwiftData
private extension AddNewListOrBlueprintItemView {
    var isUniqueName: Bool {
        switch newItemForEntity {
            case .toDoList(let list): list.items.first { $0.name.trimLowcaseEquals(name) } == nil
            case .blueprint(let blueprint): blueprint.items.first { $0.name.trimLowcaseEquals(name) } == nil
        }
    }
    
    func saveNewItemAdnDismissSheet() {
        do {
            switch newItemForEntity {
                case .toDoList(let list):
                    let item = ToDoItem(name.trimmingSpaces)
                    list.items.append(item)
                    modelContext.insert(item)
                case .blueprint(let blueprint):
                    let item = BlueprintItem(name.trimmingSpaces)
                    blueprint.items.append(item)
                    modelContext.insert(item)
            }
            try modelContext.save()
            dismissSheet()
        } catch {
            presentAlert = true
        }
    }
}

#Preview {
    @Previewable @State var isSheetPresented = true
    NavigationStack {
        VStack { }
            .navigationTitle("List: \"Grocries\"")
    }
    AddNewListOrBlueprintItemView(
        .toDoList(
            entity: ToDoList("Sample List", details: "Sample details where something relevant is highlighted.")),
        isSheetPresented: $isSheetPresented)
}
