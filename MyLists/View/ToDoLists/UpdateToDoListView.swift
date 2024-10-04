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
    @State private var presentAlert = false
    
    let list: ToDoList
    
    init(_ list: ToDoList) {
        self.list = list
        self.name = list.name
        self.details = list.details
    }
    
    var body: some View {
        VStack {
            Form {
                Section("Fields:") {
                    Group {
                        TextField("New name", text: $name.max(SizeConstraints.name))
                            .font(.title3)
                            .focused($focusState, equals: .name)
                            .onSubmit { focusState = .details }
                        
                        TextField("New details", text: $details.max(SizeConstraints.details), axis: .vertical)
                            .font(.headline.weight(.light))
                            .focused($focusState, equals: .details)
                            .lineLimit(SizeConstraints.detailsFieldLineLimit, reservesSpace: true)
                            .onChange(of: details) { _, _ in
                                if details.last == "\n" {
                                    details = String(details.dropLast())
                                    focusState = nil
                                }
                            }
                    }
                    .foregroundStyle(Color.primary)
                }
                .font(.subheadline.weight(.medium))
            }
            .scrollDisabled(true)
            .frame(height: Sizes.newEntityFormHeight)
            .onAppear {
                focusState = .name
            }
            .roundClipped()
            
            Spacer()
            
            buttonsStack
                .padding(.bottom, Sizes.exitOrSaveBottomPadding)
        }
        .foregroundStyle(Color.cyan)
        .alert(isPresented: $presentAlert) {
            Alert.genericError
        }
        .onAppear {
            name = list.name
            details = list.details
        }
        .padding(.top, Sizes.updateEtityViewTopPadding)
        .navigationTitle("List update")
    }
}

// MARK: - UI

private extension UpdateToDoListView {
    enum Field: Hashable {
        case name
        case details
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
        Button { updateListAndDismiss() } label: { Text("Save") }
            .disabled(isSaveButtonDisabled)
    }
    
    var exitButton: some View {
        Button { dismiss() } label: { Text("Exit") }
    }
}

// MARK: - SwiftData

fileprivate extension UpdateToDoListView {
    var isUniqueName: Bool {
        lists.first { $0.name.trimLowcaseEquals(name) } == nil
    }
    
    var didChangeDetails: Bool {
        details != list.details
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || (!isUniqueName && !didChangeDetails)
    }
    
    func updateListAndDismiss() {
        list.name = name
        list.details = details
        do {
            try modelContext.save()
            dismiss()
        } catch {
            presentAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        UpdateToDoListView(ToDoList(name: "List to be edited", details: "List details"))
    }
}
