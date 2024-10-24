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
    
    let newItemForEntity: NewEntityItem
    @State private var namesList: [String] = []
    
    init(_ newItemForEntity: NewEntityItem, isSheetPresented: Binding<Bool>) {
        self.newItemForEntity = newItemForEntity
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                newItemForEntity.image
                
                Text(headerTitle).font(.title3)
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
                            let newName = name.asInput
                            guard !newName.isEmptyAsInput else {
                                focusState = .name
                                return
                            }
                            if /*!newName.isEmptyAsInput && */!isUnique(newName: newName) {
                                invalidNameSent = isSaveButtonDisabled
                            } else if /*!name.isEmptyAsInput &&*/ !isSaveButtonDisabled && isUnique(newName: newName) {
                                addToList(newName: newName)
                                name = ""
                                focusState = .name
                            } else if /*newName.isEmpty &&*/ !namesList.isEmpty {
                                saveNewItemsAndDismissSheet()
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
                        
            if !namesList.isEmpty {
                List {
                    ForEach(namesList, id: \.self) { name in
                        Text(name)
                            .font(.headline.weight(.light))
                    }.onDelete(perform: deleteListItem)
                }
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
    
    var showNameUnavailableMessage: Bool {
        invalidNameSent && isSaveButtonDisabled
    }
    
    var showEmptyNameMessage: Bool {
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
                if isAddMoreButtonEnabled {
                    Spacer()
                    addMoreButton
                }
                Spacer()
            }
        }
        .font(.title2)
    }
    
    var addMoreButton: some View {
        Button {
            let newName = name.asInput
            invalidNameSent = isSaveButtonDisabled && !newName.isEmptyAsInput
            if !isSaveButtonDisabled && isUnique(newName: newName) && !newName.isEmptyAsInput {
                withAnimation { addToList(newName: newName) }
                name = ""
            }
        } label: {
            HStack(spacing: 4) {
                Image.plus.sizedToFit()
            }
        }
    }
    
    var saveButton: some View {
        Button { saveNewItemsAndDismissSheet() } label: { Text("Save") }
            .disabled(isSaveButtonDisabled)
    }
    
    var exitButton: some View {
        Button { dismissSheet() } label: { Text("Exit") }
    }
}

// MARK: - SwiftData

private extension AddNewListOrBlueprintItemView {
    func deleteListItem(_ indexSet: IndexSet) {
        if let first = indexSet.first {
            withAnimation {
                namesList = namesList.filter { $0 != namesList[first] }
            }
        }
    }
    
    var isSaveButtonDisabled: Bool {
        (namesList.isEmpty && (!name.isEmptyAsInput && !isUnique(newName: name))) ||
        (namesList.isEmpty && name.isEmptyAsInput) ||
        (!name.isEmptyAsInput && !isUnique(newName: name))
    }

    var isAddMoreButtonEnabled: Bool {
        !name.isEmptyAsInput && isUnique(newName: name)
    }
    
    func isUnique(newName new: String) -> Bool {
        let newName = new.asInput
        guard namesList.first(where: { $0.trimLowcaseEquals(newName)}) == nil else { return false }
        return switch newItemForEntity {
            case .toDoList(let list): list.items.first { $0.name.trimLowcaseEquals(newName) } == nil
            case .blueprint(let blueprint): blueprint.items.first { $0.name.trimLowcaseEquals(newName) } == nil
        }
    }
    
    func addTextFieldNameToListIfValid() {
        let newName = name.asInput
        if !name.isEmptyAsInput && isUnique(newName: newName) {
            addToList(newName: name)
        }
    }
    
    func saveNewItemsAndDismissSheet() {
        addTextFieldNameToListIfValid()
        do {
            switch newItemForEntity {
                case .toDoList(let list):
                    for newName in namesList {
                        let item = ToDoItem(newName.asInput)
                        list.items.append(item)
                        modelContext.insert(item)
                    }
                case . blueprint(let blueprint):
                    for newName in namesList {
                        let item = BlueprintItem(newName.asInput)
                        blueprint.items.append(item)
                    }
            }
            try modelContext.save()
            dismissSheet()
        } catch {
            presentAlert = true
        }
    }
    
    /// Expects 'newName' to be the result = name.asInput
    func addToList(newName: String) {
        withAnimation {
            namesList = [newName] + namesList
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
            entity: ToDoList("Sample List", details: "Sample details where something relevant is highlighted.")
        ),
        isSheetPresented: $isSheetPresented
    )
}
