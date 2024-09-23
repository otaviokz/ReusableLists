//
//  EditItemView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI

struct AddToDoItemView: SheetWrappedViewable {
    @Environment(\.modelContext) private var modelContext
    
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var itemPriority: Priority = .low
    @State private var itemDone: Bool = false
    @State private var showAlert = false
    @State var isSheetPresented: Binding<Bool>
    let list: ToDoList
    
    init(_ list: ToDoList, isSheetPresented: Binding<Bool>) {
        self.list = list
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 32) {
                Form {
                    HStack {
                        TextField("Name", text: $name.max(ToDoItem.nameSizeLimit))
                            .font(.title3)
                            .focused($focusState, equals: .name)
                            .onSubmit {
                                focusState = nil
                            }
                            
                        Spacer()
                        (itemDone ? Images.checkBoxTicked : Images.checkBox)
                            .sizedToFit()
                            .foregroundStyle(Color.cyan)
                            .onTapGesture { itemDone.toggle() }
                    }

                }
                .frame(height: 112)
                .roundClipped()
                    
                Button {
                    do {
                        try saveItem()
                        dismissSheet()
                    } catch {
                        showAlert = true
                    }
                } label: {
                    Text("Save")
                        .font(.title2)
                }
                .disabled(isSaveButtonDisabled)
                .foregroundStyle(Color.cyan.opacity(isSaveButtonDisabled ? 0 : 1))
                .padding(.top, 12)
                .alert(isPresented: $showAlert) {
                    Alert.genericErrorAlert
                }
            }
            
            Spacer()
        }
        .onAppear {
            focusState = .name
        }
    }
}

fileprivate extension AddToDoItemView {
    enum Field: Hashable {
        case name
    }
    
    var isUniqueName: Bool {
        list.items.first { $0.name.trimmingSpacesLowercasedEquals(name)
        } == nil
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func saveItem() throws {
        let item = ToDoItem(name: name.trimmingSpaces, done: itemDone)
        modelContext.insert(item)
        list.items.append(item)
        try modelContext.save()
    }
}

#Preview {
    @Previewable @State var isSheetPresented = true
    let list = ToDoList(name: "Groceries list")
    NavigationStack {
        AddToDoItemView(list, isSheetPresented: $isSheetPresented)
    }
}
