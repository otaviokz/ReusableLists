//
//  AddToDoListView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

struct AddToDoListView: SheetWrappedViewable {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var lists: [ToDoList]
    @FocusState private var focusState: Field?
    @State var name: String = ""
    @State var details: String = ""
    @State private var showAlert = false
    @State var isSheetPresented: Binding<Bool>
    
    init(isSheetPresented: Binding<Bool>) {
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("New ToDoList")
                .font(.title3)
                .foregroundStyle(Color.cyan)
                .padding(.top, 24)
            
            Form {
                Section("Name") {
                    TextField("Your new ToDoList's name", text: $name.max(SizeConstraints.name))
                        .font(.title3.weight(.medium))
                        .focused($focusState, equals: .name)
                        .onSubmit {
                            focusState = .details
                        }
                        .submitLabel(.next)
                }
                
                Section("Details") {
                    TextField(
                        "Anything you should keep in mind when using this list.",
                        text: $details.max(SizeConstraints.details),
                        axis: .vertical
                    )
                        .font(.title3.weight(.light))
                        .focused($focusState, equals: .details)
                        .lineLimit(3, reservesSpace: true)
                        .onChange(of: details) { _, _ in
                            if details.last == "\n" {
                                details = String(details.dropLast())
                                focusState = nil
                            }
                        }
                        .submitLabel(.done)
                }
            }
            .scrollDisabled(true)
            .frame(height: 257)
            .roundClipped()
           
            Spacer()
            
            buttonsStack
                .padding(.bottom, 8)            
        }
        .onAppear {
            focusState = .name
        }
        .alert(isPresented: $showAlert) {
            Alert.genericErrorAlert
        }
    }
}

// MARK: - UI

fileprivate extension AddToDoListView {
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
        .foregroundStyle(Color.cyan)
    }
    
    var saveButton: some View {
        Button { saveListAndDismissSheet() } label: { Text("Save") }
            .disabled(isSaveButtonDisabled)
    }
    
    var exitButton: some View {
        Button { dismissSheet() } label: { Text("Exit") }
    }
}

// MARK: - SwiftData

private extension AddToDoListView {
    var isUniqueName: Bool {
        lists.first { $0.name.trimLowcaseEquals(name) } == nil
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func saveListAndDismissSheet() {
        let list = ToDoList(name: name.trimmingSpaces, details: details.trimmingSpaces)
        modelContext.insert(list)
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
        AddToDoListView(isSheetPresented: $isSheetPresented)
    }
}
