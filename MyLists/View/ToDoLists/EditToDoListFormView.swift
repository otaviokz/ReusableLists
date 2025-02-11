//
//  ToDoListUpdateView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 22/09/2024.
//

import SwiftUI
import SwiftData

struct EditToDoListFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var lists: [ToDoList]
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var details: String = ""
    @State private var presentAlert = false
    @State private var priority = false
    @State private var oldPriority = false
    @State var priorityIconScale = CGPoint(x: 1, y: 1)
    
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
                        editNameAndPriorityView
                            .onAppear {
                                name = list.name
                                details = list.details
                                priority = list.priority
                                oldPriority = list.priority
                            }
                        TextField("New details", text: $details.max(DataFieldsSizeLimit.details), axis: .vertical)
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
        
        .padding(.top, Sizes.updateEtityViewTopPadding)
        .navigationTitle("List update")
    }
}

// MARK: - UI

private extension EditToDoListFormView {
    var editNameAndPriorityView: some View {
        HStack {
            TextField("New name", text: $name.max(DataFieldsSizeLimit.name))
                .font(.title3)
                .focused($focusState, equals: .name)
                .onSubmit { focusState = .details }
            
            Image.priority.sizedToFitSquare(side: 22).foregroundStyle(priority ? .red : .disabled)
                .transformEffect(CGAffineTransformMakeScale(priorityIconScale.x, priorityIconScale.y))
                .onTapGesture {
                    withAnimation {
                        priority.toggle()
                    }
                }
        }
        
    }
    
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
            .foregroundStyle(isSaveButtonDisabled ? Color.disabled : Color.cyan)
    }
    
    var exitButton: some View {
        Button { dismiss() } label: { Text("Exit") }
    }
}

// MARK: - SwiftData

fileprivate extension EditToDoListFormView {
    // Accepts the same name, but with different capilaization
    var isNameUnique: Bool {
        lists.first { $0.name == name.asInput } == nil
    }
    
    var didUpdateList: Bool {
        details.asInput != list.details || isNameUnique || priority != oldPriority
    }
    
    var isSaveButtonDisabled: Bool {
        name.asInput.isEmpty || !didUpdateList
    }
    
    func updateListAndDismiss() {
        list.name = name
        list.details = details
        list.priority = priority
        do {
            try modelContext.save()
            dismiss()
        } catch {
            logger.error("Error updating list: \(error)")
            presentAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        EditToDoListFormView(ToDoList("List to be edited", details: "List details"))
    }
}
