//
//  NewEntityItem.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 18/10/2024.
//

import SwiftUI

struct NewListOrBlueprintItemFormView: View, SheetWrappedViewable {
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var invalidNameSent = false
    @State private var presentAlert = false
    @State var isSheetPresented: Binding<Bool>
    @State private var namesList: [String] = []
    @State private var scrollId: String?
    @State private var scrollViewProxy: ScrollViewProxy?
    private let newItemForEntity: NewEntityItem
    private let isUniqueNameInEntity: (String) -> Bool
    private let createAndInsertNewItems: ([String]) throws -> Void
    
    init(
        _ newItemForEntity: NewEntityItem,
        isSheetPresented: Binding<Bool>,
        isUniqueNameInEntity: @escaping (String) -> Bool,
        createAndInsertNewItems: @escaping ([String]) throws -> Void
    ) {
        self.newItemForEntity = newItemForEntity
        self.isSheetPresented = isSheetPresented
        self.isUniqueNameInEntity = isUniqueNameInEntity
        self.createAndInsertNewItems = createAndInsertNewItems
    }
    
    var body: some View {
        VStack(spacing: 4) {
            headerView
                .padding(.top, 28)
            
            formView
                .padding(.top, 4)
            
            if showNameUnavailableMessage {
                nameNotAvailableMessage
            }
            
            if namesList.isEmpty {
                Spacer()
            } else {
                itemsListView
                    .padding(.top, 8)
                    .padding(.bottom, 2)
            }
                
            if !namesList.isEmpty {
                Spacer()
            }
            
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

private extension NewListOrBlueprintItemFormView {
    enum Field: Hashable {
        case name
    }
    
    var headerView: some View {
        HStack {
            newItemForEntity.image
            Text(newItemForEntity.name).font(.title3)
        }
    }
    
    var formView: some View {
        Form {
            Section("Fields:") {
                TextField(
                    "Item Name (max \(DataFieldsSizeLimit.name) characters)",
                    text: $name.max(DataFieldsSizeLimit.name)
                )
                .font(.title3)
                .foregroundStyle(Color.primary)
                .focused($focusState, equals: .name)
                .onChange(of: name) { invalidNameSent = false }
                .submitLabel(.send)
                .onSubmit {
                    if name.isEmptyAsInput && !namesList.isEmpty {
                        saveNewItemsAndDismissSheet()
                    }
                    guard !name.isEmptyAsInput else {
                        focusState = .name
                        return
                    }
                    let newName = name.asInput
                    if !isUnique(newName: newName) {
                        invalidNameSent = isSaveButtonDisabled
                    } else if !isSaveButtonDisabled && isUnique(newName: newName) {
                        saveNewItemsAndDismissSheet()
                    }
                    focusState = .name
                }
            }
            .font(.subheadline.weight(.medium))
        }
        .frame(height: Sizes.newItemFormHeight)
        .roundClipped()
    }
    
    var itemsListView: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(namesList, id: \.self) { name in
                    Text(name)
                        .font(.headline.weight(.light))
                        .id(name)
                    
                }
                .onDelete(perform: deleteListItem)
                .listRowBackground(Color.clear)
                
            }
            .animation(.easeInOut, value: namesList)
            .roundBordered(borderColor: Color.cyan, boderWidht: 1)
            .listStyle(.plain)
            .padding(.horizontal, 12)
            .onAppear {
                scrollViewProxy = proxy
            }
        }
    }
    
    var showNameUnavailableMessage: Bool {
        invalidNameSent && isSaveButtonDisabled
    }
    
    var nameNotAvailableMessage: some View {
        Text(newItemForEntity.nameNotAvailableMessage)
            .font(.headline.weight(.light))
            .foregroundStyle(Color.red)
            .frame(alignment: .leading)
            .padding(.top, -6)
            .padding(.horizontal, 16)
    }
    
    var addMoreButton: some View {
        Button {
            let newName = name.asInput
            invalidNameSent = isSaveButtonDisabled && !newName.isEmptyAsInput
            if !isSaveButtonDisabled && isUnique(newName: newName) && !newName.isEmptyAsInput {
                withAnimation(.linear(duration: 0.125)) {
                    addToList(newName: newName)
                } completion: {
                    scrollId = newName
                    if let scrollViewProxy = scrollViewProxy {
                        withAnimation(.linear(duration: 0.125)) {
                            scrollViewProxy.scrollTo(scrollId, anchor: .top)
                        }
                    }
                }
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
    
    var buttonsStack: some View {
        HStack {
            if !isSaveButtonDisabled && isAddMoreButtonEnabled {
                Spacer()
                exitButton
                Spacer()
                saveButton
                Spacer()
                addMoreButton
                Spacer()
            } else if (!isSaveButtonDisabled && !isAddMoreButtonEnabled) ||
                      (!namesList.isEmpty && isSaveButtonDisabled && !isAddMoreButtonEnabled) {
                Spacer()
                exitButton
                Spacer()
                saveButton
                Spacer()
            } else if isSaveButtonDisabled && isAddMoreButtonEnabled {
                Spacer()
                exitButton
                Spacer()
                addMoreButton
                Spacer()
            } else {
                exitButton
            }
        }
        .font(.title2)
    }
}

// MARK: - SwiftData

private extension NewListOrBlueprintItemFormView {
    func deleteListItem(_ indexSet: IndexSet) {
        if let first = indexSet.first {
            namesList = namesList.filter { $0 != namesList[first] }
        }
    }
    
    var isSaveButtonDisabled: Bool {
        switch (namesList.isEmpty, name.isEmptyAsInput, isUnique(newName: name.asInput)) {
            case (true, false, false): true
            case (true, true, _): true
            case (_, false, false): true
            default: false
        }
    }

    var isAddMoreButtonEnabled: Bool {
        !name.isEmptyAsInput && isUnique(newName: name)
    }
    
    func isUnique(newName new: String) -> Bool {
        let newName = new.asInput
        guard namesList.first(where: { $0.asInputLowercasedEquals(newName)}) == nil else { return false }
        return isUniqueNameInEntity(newName)
    }
    
    func saveNewItemsAndDismissSheet() {
        let newName = name.asInput
        if !newName.isEmpty, isUnique(newName: newName) {
            addToList(newName: newName)
        }
        
        dismissSheet()
        
        Task {
            do {
                try await Task.sleep(nanoseconds: WaitTimes.sheetDismissAndInsertOrRemove)
                
                try withAnimation {
                    try createAndInsertNewItems(namesList)
                }
            } catch {
                logger.error("Error saveNewItemsAndDismissSheet(): \(error.localizedDescription)")
                presentAlert = true
            }
        }
    }
    
    /// Expects 'newName' to be the result = name.asInput
    func addToList(newName: String) {
        withAnimation {
            namesList = [newName] + namesList
            name = "" // Because of "Assign on read", we can't set name to "" before saving it's content
        }
    }
}

#Preview {
    @Previewable @State var isSheetPresented = true
    NavigationStack {
        VStack {
            NewListOrBlueprintItemFormView(
                .toDoList(entity: ToDoList("Sample List", details: "Sample details for preview purposes.")),
                isSheetPresented: $isSheetPresented,
                isUniqueNameInEntity: {_ in true},
                createAndInsertNewItems: {_ in }
            )
        }
        .navigationTitle("List: \"Grocries\"")
    }
}
