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
    @State private var showAlert = false
    @State var isSheetPresented: Binding<Bool>
    let list: ToDoList
    
    init(_ list: ToDoList, isSheetPresented: Binding<Bool>) {
        self.list = list
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("New item for \"\(list.name)\"")
                .font(.title2)
                .foregroundStyle(Color.cyan)
                .padding(.top, 24)
            
            Form {
                Section("Name Field") {
                        TextField("Your new item's name", text: $name.max(SizeConstraints.name))
                            .font(.title3)
                            .focused($focusState, equals: .name)
                            .onSubmit {
                                focusState = nil
                            }
                }
            }
            .frame(height: 112)
            .roundClipped()
                
            buttonsStack
            
            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert.genericErrorAlert
        }
        .onAppear {
            focusState = .name
        }
    }
}

// MARK: - UI

extension AddToDoItemView {
    enum Field: Hashable {
        case name
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
        .foregroundStyle(Color.cyan)
    }
    
    var saveButton: some View {
        Button { saveTodoItemAndDismissSheet() } label: { Text("Save") }
            .disabled(isSaveButtonDisabled)
    }
    
    var exitButton: some View {
        Button { dismissSheet() } label: { Text("Exit") }
    }
}

// MARK: - SwiftData

fileprivate extension AddToDoItemView {
    var isUniqueName: Bool {
        list.items.first { $0.name.trimLowcaseEquals(name)
        } == nil
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func saveTodoItemAndDismissSheet() {
        let item = ToDoItem(name: name.trimmingSpaces, done: false)
        list.items.append(item)
        modelContext.insert(item)
        do {
            try modelContext.save()
            dismissSheet()
        } catch {
            showAlert = true
        }
    }
}

#Preview {
    @Previewable @State var isSheetPresented = true
    NavigationStack {
        VStack { }
            .navigationTitle("Groceries")
    }
    .sheet(isPresented: $isSheetPresented) {
        AddToDoItemView(ToDoList(name: "Groceries"), isSheetPresented: $isSheetPresented)
    }
}
