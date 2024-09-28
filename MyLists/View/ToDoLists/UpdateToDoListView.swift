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
                        .lineLimit(3, reservesSpace: true)
                        .onChange(of: details) { _, _ in
                            if details.last == "\n" {
                                details = String(details.dropLast())
                                focusState = nil
                            }
                        }
                }
            }
            .scrollDisabled(true)
            .frame(height: 250)
            .onAppear {
                focusState = .name
            }
            .roundClipped()
            
            buttonsStack
            
            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert.genericErrorAlert
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
        .foregroundStyle(Color.cyan)
    }
    
    var saveButton: some View {
        Button {
            updateList()
            dismiss()
        } label: {
            Text("Save")
        }
        .disabled(isSaveButtonDisabled)
    }
    
    var exitButton: some View {
        Button { dismiss() } label: { Text("Exit") }
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
    
    func updateList() {
        list.name = name
        list.details = details
        do {
            try modelContext.save()
        } catch {
            showAlert = true
        }
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
