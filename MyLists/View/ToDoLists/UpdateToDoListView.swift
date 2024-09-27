//
//  ToDoListUpdateView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 22/09/2024.
//

import SwiftUI
import SwiftData

struct UpdateToDoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var lists: [ToDoList]
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var details: String = ""
    @State private var showAlert = false
    @State private var showDeleteConfirmation = false
    
    let list: ToDoList
    
    init(_ list: ToDoList) {
        self.list = list
        self.name = list.name
        self.details = list.details
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Form {
                Section("Name") {
                    TextField("New name", text: $name.max(SizeConstraints.name))
                        .font(.title3.weight(.medium))
                        .focused($focusState, equals: .name)
                        .onSubmit {
                            focusState = .details
                        }
                }
                Section("Details") {
                    TextField("New details", text: $details.max(SizeConstraints.details), axis: .vertical)
                        .font(.title3.weight(.light))
                        .focused($focusState, equals: .details)
                        .lineLimit(4, reservesSpace: true)
                        .onChange(of: details) { _, _ in
                            if details.last == "\n" {
                                details = String(details.dropLast()).trimmingSpaces
                                focusState = nil
                            }
                        }
                }
            }
            .autocorrectionDisabled()
            .scrollDisabled(true)
            .frame(height: 282)
            .onAppear {
                focusState = .name
            }
            .roundClipped()
            
            buttonsStack
            
            Spacer()
        }
        .actionSheet(isPresented: $showDeleteConfirmation) {
            ActionSheet(
                title: Text("Are you sure you want to delete \"\(list.name)\" and all its items"),
                message: nil,
                buttons: [
                    .cancel(Text("No")) { showDeleteConfirmation = false},
                    .destructive(Text("Yes")) {
                        do {
                            try deleteList()
                            dismiss()
                        } catch {
                            showAlert = true
                        }
                    }
                ]
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image.trash
                    .foregroundStyle(Color.red)
                    .onTapGesture {
                        showDeleteConfirmation = true
                    }
            }
        }
        .onAppear {
            name = list.name
            details = list.details
        }
        .navigationTitle("Edit \"\(list.name)\"")
    }
}

extension UpdateToDoListView {
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
                try updateList()
                dismiss()
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
        Button { dismiss() } label: { Text("Exit") }
            .foregroundStyle(Color.cyan)
        
    }
}

// MARK: - CoreData
fileprivate extension UpdateToDoListView {
    var isUniqueName: Bool {
        lists.first { $0.name.trimLowcaseEquals(name) } == nil
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func updateList() throws {
        list.name = name
        list.details = details
        try modelContext.save()
    }
    
    func deleteList() throws {
        modelContext.delete(list)
        try modelContext.save()
    }
}

// MARK: - Focus
extension UpdateToDoListView {
    enum Field: Hashable {
        case name
        case details
    }
 }

#Preview {
    NavigationStack {
        UpdateToDoListView(ToDoList(name: "List to be edited", details: "List details"))
    }
}
