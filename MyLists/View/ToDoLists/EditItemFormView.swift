//
//  EditItemFormView.swift
//  ReusableLists
//
//  Created by okz on 30/01/25.
//

import SwiftUI

struct EditItemFormView: View {
    @FocusState private var focusState: Field?
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var priority = false
    private let oldName: String
    private let oldPriority: Bool
    private let item: ToDoItem
    private let list: ToDoList
    private let onEdited: (ToDoItem) -> Void
    
    init(
        _ item: ToDoItem,
        list: ToDoList,
        onEdited: @escaping (ToDoItem) -> Void
    ) {
        self.item = item
        self.list = list
        self.oldName = item.name.copy() as! String
        self.oldPriority = item.priority ? true : false
        self.onEdited = onEdited
        self.name = item.name.copy() as? String ?? ""
        self.priority = item.priority ? true : false
    }
    
    var body: some View {
        VStack(spacing: 4) {
            headerView
                .padding(.top, 28)
            
            formView
                .padding(.top, 4)
               
            if nameAlreadyUsedByAnotherItem {
                nameAlreadyUsedByAnotherItemMessage
            }
            
            Spacer()
            
            buttonsStack
                .padding(.vertical, Sizes.exitOrSaveBottomPadding)
                .font(.title3)
        }
        .onAppear {
            name = item.name
            priority = item.priority
            focusState = .name
        }
    }
}

// MARK: - UI

private extension EditItemFormView {
    enum Field: Hashable {
        case name
    }
    
    var headerView: some View {
        HStack {
            Image.todolist
            Text(list.name).font(.title3)
        }
    }
    
    var nameAlreadyUsedByAnotherItemMessage: some View {
        Text("⚠ Another iten named \"\(name.asInput)\" already exists for this List.")
            .font(.headline.weight(.light))
            .foregroundStyle(Color.red)
            .frame(alignment: .leading)
            .padding(.top, -6)
            .padding(.horizontal, 16)
    }
    
    var nameAlreadyUsedByAnotherItem: Bool {
        list.items.first { $0.name == name.asInput && $0 != item } != nil
    }
    
    var formView: some View {
        Form {
            HStack {
                TextField(
                    "Item Name (max \(DataFieldsSizeLimit.listItemName) characters)",
                    text: $name.max(DataFieldsSizeLimit.listItemName)
                )
                .font(.title3)
                .foregroundStyle(Color.primary)
                .focused($focusState, equals: .name)
                .submitLabel(.done)
                
                Image.priority
                    .sizedToFitHeight(22)
                    .onTapGesture {
                        withAnimation {
                            priority.toggle()
                        }
                    }
                    .foregroundStyle(priority ? .red : .disabled)
                    .fontWeight(priority ? .semibold : .regular)
            }
        }
        .frame(height: Sizes.newItemFormHeight)
        .roundClipped()
    }
    
    var buttonsStack: some View {
        HStack {
            Spacer()
            Button { discardEditsAndDismissSheet() } label: { Text("Exit") }
            Spacer()
            Button {
                if name.asInput == oldName || priority != oldPriority {
                    saveEditsAndDismissSheet()
                }
            } label: {
                Text("Save")
            }
            .disabled(isSaveButtonDisabled)
            .foregroundStyle(isSaveButtonDisabled ? Color.disabled : Color.cyan)
            
            Spacer()
        }
        .font(.title2)
        .foregroundStyle(Color.cyan)
    }
    
    var isSaveButtonDisabled: Bool {
        !hasEdits || nameAlreadyUsedByAnotherItem || name.isEmptyAsInput
    }
}

// MARK: - SwiftData

private extension EditItemFormView {
    var hasEdits: Bool {
        name.asInput != oldName || priority != oldPriority
    }
    
    func saveEditsAndDismissSheet() {
        item.name = name
        item.priority = priority
        
        Task {
            dismiss()
            try? await Task.sleep(nanoseconds: WaitTimes.dismissAndEdit)
            onEdited(item)
        }
    }
    
    func discardEditsAndDismissSheet() {
        dismiss()
    }
}
