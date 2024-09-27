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
    @State private var itemDone: Bool = false
    @State private var showAlert = false
    @State var isSheetPresented: Binding<Bool>
    let list: ToDoList
    
    init(_ list: ToDoList, isSheetPresented: Binding<Bool>) {
        self.list = list
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("New item for \(list.name)")
                .font(.title2)
                .foregroundStyle(Color.cyan)
                .padding(.top, 24)
            
            Form {
                HStack {
                    TextField("Name", text: $name.max(SizeConstraints.name))
                        .font(.title3)
                        .focused($focusState, equals: .name)
                        .onSubmit {
                            focusState = nil
                        }
                        
                    Spacer()
                }

            }
            .autocorrectionDisabled()
            .frame(height: 112)
            .roundClipped()
                
            buttonsStack
            
            Spacer()
        }
        .onAppear {
            focusState = .name
        }
    }
}

extension AddToDoItemView {
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
        Button {
            do {
                try saveItem()
                dismissSheet()
            } catch {
                showAlert = true
            }
        } label: {
            Text("Save")
        }
        .foregroundStyle(Color.cyan.opacity(isSaveButtonDisabled ? 0 : 1))
        .disabled(isSaveButtonDisabled)
        .alert(isPresented: $showAlert) {
            Alert.genericErrorAlert
        }
    }
    
    var exitButton: some View {
        Button { dismissSheet() } label: { Text("Exit") }
            .foregroundStyle(Color.cyan)
        
    }
}

fileprivate extension AddToDoItemView {
    enum Field: Hashable {
        case name
    }
    
    var isUniqueName: Bool {
        list.items.first { $0.name.trimLowcaseEquals(name)
        } == nil
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func saveItem() throws {
        let item = ToDoItem(name: name.trimmingSpaces, done: false)
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
