//
//  EditItemFormView.swift
//  ReusableLists
//
//  Created by okz on 30/01/25.
//

import SwiftUI

struct EditToDoListItemFormView: View {
    @FocusState private var focusState: Field?
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isPriority = false
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
        self.isPriority = item.priority ? true : false
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
                .padding(.vertical, 8)
                .font(.title3)
        }
        .onAppear {
            name = item.name
            isPriority = item.priority
            focusState = .name
        }
    }
}

// MARK: - UI

private extension EditToDoListItemFormView {
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
        list.items.first { $0.name.asInputLowcaseEquals(name) && $0.id != item.id } != nil
    }
    
    var formView: some View {
        Form {
            HStack {
                TextField(
                    "Item Name (max \(DataFieldsSizeLimit.name) characters)",
                    text: $name.max(DataFieldsSizeLimit.name)
                )
                .font(.title3)
                .foregroundStyle(Color.primary)
                .focused($focusState, equals: .name)
                .submitLabel(.done)
                
                Image.priority
                    .sizedToFitHeight(22)
                    .foregroundStyle(isPriority ? Color.red : Color.gray)
                    .onTapGesture {
                        isPriority.toggle()
                    }
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
                if !name.asInputLowcaseEquals(oldName) || isPriority != oldPriority {
                    saveEditsAndDismissSheet()
                }
            } label: {
                Text("Save")
            }
            .disabled(isSaveButtonDisabled)
            
            Spacer()
        }
    }
    
    var isSaveButtonDisabled: Bool {
        !hasEdits || nameAlreadyUsedByAnotherItem || name.isEmptyAsInput
    }
}

// MARK: - SwiftData

private extension EditToDoListItemFormView {
    var hasEdits: Bool {
        !name.asInputLowcaseEquals(oldName) || isPriority != oldPriority
    }
    
    func saveEditsAndDismissSheet() {
        item.name = name
        item.priority = isPriority
        
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
