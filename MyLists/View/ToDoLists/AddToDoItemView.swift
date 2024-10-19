//
//  AddToDoItemView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI

struct AddToDoItemView: SheetWrappedViewable {
    @Environment(\.modelContext) private var modelContext
    
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var presentAlert = false
    @State var isSheetPresented: Binding<Bool>
    @State var invalidNameSent = false
    
    let list: ToDoList
    
    init(_ list: ToDoList, isSheetPresented: Binding<Bool>) {
        self.list = list
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image.todolist
                Text("List: \"\(list.name)\"")
                    .font(.title3)
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
                                invalidNameSent = isSaveButtonDisabled
                                if !isSaveButtonDisabled {
                                    saveTodoItemAndDismissSheet()
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
            
            Spacer()
            
            buttonsStack
                .padding(.bottom, 8)
        }
        .foregroundStyle(Color.cyan)
        .alert(isPresented: $presentAlert) {
            Alert.genericError
        }
        .onAppear {
            focusState = .name
        }
    }
}

// MARK: - UI

private extension AddToDoItemView {
    enum Field: Hashable {
        case name
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    var showNameUnavailableMessage: Bool {
        invalidNameSent && isSaveButtonDisabled
    }

    var nameNotAvailableMessage: some View {
        Text("⚠ An item named \"\(name)\" already exists for this List.")
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
                Spacer()
            }
        }
        .font(.title2)
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
        list.items.first { $0.name.trimLowcaseEquals(name) } == nil
    }
    
    func saveTodoItemAndDismissSheet() {
        let item = ToDoItem(name.trimmingSpaces)
        list.items.append(item)
        modelContext.insert(item)
        do {
            try modelContext.save()
            dismissSheet()
        } catch {
            presentAlert = true
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
        AddToDoItemView(ToDoList("Groceries"), isSheetPresented: $isSheetPresented)
    }
}
