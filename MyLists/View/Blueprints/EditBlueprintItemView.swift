//
//  EditBlueprintItemView.swift
//  ReusableLists
//
//  Created by okz on 31/01/25.
//

import SwiftUI

struct EditBlueprintItemView: View, SheetWrappedViewable {
    @FocusState private var focusState: Field?
    @State private var name = ""
    @State private var isPriority = false
    private let oldName: String
    private let oldPriority: Bool
    private let item: BlueprintItem
    private let blueprint: Blueprint
    @State var isSheetPresented: Binding<Bool>
    let onEdited: (BlueprintItem) -> Void
    
    init(_ item: BlueprintItem,
         blueprint: Blueprint,
         isSheetPresented: Binding<Bool>,
         onEdited: @escaping (BlueprintItem) -> Void
    ) {
        self.item = item
        self.blueprint = blueprint
        self.oldName = item.name.copy() as! String
        self.oldPriority = item.priority ? true : false
        self.isSheetPresented = isSheetPresented
        self.onEdited = onEdited
        name = item.name.copy() as? String ?? ""
        isPriority = item.priority ? true : false
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
        .onAppear {
            name = item.name
            isPriority = item.priority
            focusState = .name
        }
    }
}

// MARK: - UI

private extension EditBlueprintItemView {
    enum Field: Hashable {
        case name
    }
    
    var headerView: some View {
        HStack {
            Image.blueprint
            Text(blueprint.name).font(.title3)
        }
    }
    
    var nameAlreadyUsedByAnotherItemMessage: some View {
        Text("⚠ Another iten named \"\(name)\" already exists for this Blueptint.")
            .font(.headline.weight(.light))
            .foregroundStyle(Color.red)
            .frame(alignment: .leading)
            .padding(.top, -6)
            .padding(.horizontal, 16)
    }
    
    var nameAlreadyUsedByAnotherItem: Bool {
        blueprint.items.first { $0.name.asInputLowcaseEquals(name) && $0.id != item.id
        } != nil
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
        !hasEdits ||
        nameAlreadyUsedByAnotherItem ||
        name.isEmptyAsInput
    }
}

// MARK: - SwiftData

private extension EditBlueprintItemView {
    var hasEdits: Bool {
        !name.asInputLowcaseEquals(oldName) || isPriority != oldPriority
    }
    
    func saveEditsAndDismissSheet() {
        item.name = name
        item.priority = isPriority
        
        Task {
            dismissSheet()
            try? await Task.sleep(nanoseconds: WaitTimes.dismissAndEdit)
            onEdited(item)
        }
    }
    
    func discardEditsAndDismissSheet() {
        item.name = oldName
        item.priority = oldPriority
        dismissSheet()
    }
}
