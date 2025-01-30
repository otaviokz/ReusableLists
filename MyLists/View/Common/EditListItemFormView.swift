//
//  EditItemFormView.swift
//  ReusableLists
//
//  Created by okz on 30/01/25.
//

import SwiftData
import SwiftUI

struct EditListItemFormView: View, SheetWrappedViewable {
    @FocusState private var focusState: Field?
    @State var invalidNameEntered = false
    @State private var isPriority: Bool = false
    @State private var name = ""
    @State var isSheetPresented: Binding<Bool>
    let item: ToDoItem
    let list: ToDoList
    let onDone: (ToDoItem) -> Void
    
    init(
        _ item: ToDoItem,
        list: ToDoList,
        isSheetPresented: Binding<Bool>,
        onDone: @escaping (ToDoItem) -> Void
    ) {
        self.item = item
        self.list = list
        self.isSheetPresented = isSheetPresented
        self.onDone = onDone
        name = item.name
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
                .padding(.bottom, 8)
        }
        
    }
}

// MARK: - UI

private extension EditListItemFormView {
    enum Field: Hashable {
        case name
    }
    
    var headerView: some View {
        HStack {
            Image.todolist
            Text(item.name).font(.title3)
        }
    }
    
    var nameAlreadyUsedByAnotherItemMessage: some View {
        Text("⚠ Another iten named \"\(item.name)\" already exists for this List.")
            .font(.headline.weight(.light))
            .foregroundStyle(Color.red)
            .frame(alignment: .leading)
            .padding(.top, -6)
            .padding(.horizontal, 16)
    }
    
    var nameAlreadyUsedByAnotherItem: Bool {
        list.items.first { $0.name.asInputLowercasedEquals(item.name) && $0 != item } != nil
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
                .onChange(of: item.name) { invalidNameEntered = false }
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
            Button { dismissSheet() } label: { Text("Exit") }
            Spacer()
            Button { saveEditsAndDismissSheet() } label: { Text("Save") }
                .disabled(isSaveButtonDisabled)
            Spacer()
        }
    }
    
    var isSaveButtonDisabled: Bool {
        nameAlreadyUsedByAnotherItem || item.name.isEmptyAsInput
    }
}


// MARK: - CoreData

private extension EditListItemFormView {
    func saveEditsAndDismissSheet() {
        item.name = name
        item.priority = isPriority
        onDone(item)
    }
}
