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
    @State private var invalidNameEntered = false
    @State private var presentAlert = false
    @State var isSheetPresented: Binding<Bool>
    @State private var itemsList: [NamesListItem] = []
    @State private var scrollId: String?
    @State private var scrollViewProxy: ScrollViewProxy?
    @State private var isPriority: Bool = false
    private let newItemForEntity: NewEntityItem
    private let isUniqueNameInEntity: (String) -> Bool
    private let createAndInsertNewItems: ([(String, Bool)]) throws -> Void
    
    init(
        _ newItemForEntity: NewEntityItem,
        isSheetPresented: Binding<Bool>,
        isUniqueNameInEntity: @escaping (String) -> Bool,
        createAndInsertNewItems: @escaping ([(String, Bool)]) throws -> Void
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
            
            if itemsList.isEmpty {
                Spacer()
            } else {
                itemsListView
                    .padding(.top, 8)
                    .padding(.bottom, 2)
            }
                
            if !itemsList.isEmpty {
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
                HStack {
                    TextField(
                        "Item Name (max \(DataFieldsSizeLimit.name) characters)",
                        text: $name.max(DataFieldsSizeLimit.name)
                    )
                    .font(.title3)
                    .foregroundStyle(Color.primary)
                    .focused($focusState, equals: .name)
                    .onChange(of: name) { invalidNameEntered = false }
                    .submitLabel(.send)
                    .onSubmit {
                        if name.isEmptyAsInput && !itemsList.isEmpty {
                            saveNewItemsAndDismissSheet()
                        }
                        guard !name.isEmptyAsInput else {
                            focusState = .name
                            return
                        }
                        let newName = name.asInput
                        if !isUnique(newName: newName) {
                            invalidNameEntered = isSaveButtonDisabled
                        } else if !isSaveButtonDisabled && isUnique(newName: newName) {
                            saveNewItemsAndDismissSheet()
                        }
                        focusState = .name
                    }
                    
                    Image.priority
                        .sizedToFitHeight(22)
                        .foregroundStyle(isPriority ? Color.red : Color.gray)
                        .onTapGesture {
                            isPriority.toggle()
                        }
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
                ForEach(itemsList, id: \.name) { item in
                    HStack(spacing: 0) {
                        Text(item.name)
                            .font(.headline.weight(.light))
                            .id(name)
                        
                        if item.priority {
                            Spacer()
                            Image.priority.sizedToFitHeight(18).foregroundStyle(Color.red)
                        }
                    }
                    
                }
                .onDelete(perform: deleteListItem)
                .listRowBackground(Color.clear)
                
            }
            .animation(.easeInOut, value: itemsList)
            .roundBordered(borderColor: Color.cyan, boderWidht: 1)
            .listStyle(.plain)
            .padding(.horizontal, 12)
            .onAppear {
                scrollViewProxy = proxy
            }
        }
    }
    
    var showNameUnavailableMessage: Bool {
        invalidNameEntered && isSaveButtonDisabled
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
            invalidNameEntered = isSaveButtonDisabled && !newName.isEmptyAsInput
            if !isSaveButtonDisabled && isUnique(newName: newName) && !newName.isEmptyAsInput {
                withAnimation(.linear(duration: 0.125)) {
                    addToList(newName: newName, priority: isPriority)
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
                      (!itemsList.isEmpty && isSaveButtonDisabled && !isAddMoreButtonEnabled) {
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
            itemsList = itemsList.filter { $0 != itemsList[first] }
        }
    }
    
    var isSaveButtonDisabled: Bool {
        switch (itemsList.isEmpty, name.isEmptyAsInput, isUnique(newName: name.asInput)) {
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
        guard itemsList.first(where: { $0.name.asInputLowercasedEquals(newName)}) == nil else { return false }
        return isUniqueNameInEntity(newName)
    }
    
    func saveNewItemsAndDismissSheet() {
        let newName = name.asInput
        if !newName.isEmpty, isUnique(newName: newName) {
            addToList(newName: newName, priority: isPriority)
        }
        
        dismissSheet()
        
        Task {
            do {
                try await Task.sleep(nanoseconds: WaitTimes.sheetDismissAndInsertOrRemove)
                
                try withAnimation {
                    try createAndInsertNewItems(itemsList.map {($0.name, $0.priority)})
                }
            } catch {
                logger.error("Error saveNewItemsAndDismissSheet(): \(error.localizedDescription)")
                presentAlert = true
            }
        }
    }
    
    /// Expects 'newName' to be the result = name.asInput
    func addToList(newName: String, priority: Bool) {
        withAnimation {
            itemsList = [NamesListItem(name: newName, priority: priority)] + itemsList
            name = "" // Because of "Assign on read", we can't set name to "" before saving it's content
            isPriority = false
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

struct NamesListItem: Equatable {
    var name: String
    var priority: Bool
}
