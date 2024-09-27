//
//  NewListOrBlueprintView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 26/09/2024.
//

import SwiftUI
import SwiftData

struct NewListOrBlueprintView: SheetWrappedViewable {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var blueprints: [Blueprint]
    @Query private var lists: [ToDoList]
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var details: String = ""
    @State private var showAlert = false
    @State var isSheetPresented: Binding<Bool>
    var entity: Entity
    
    init(isSheetPresented: Binding<Bool>, entity: Entity) {
        self.isSheetPresented = isSheetPresented
        self.entity = entity
    }
    
    var body: some View {
        VStack(spacing: 11) {
            Text(entity.creteNewTitle)
                .font(.title2)
                .foregroundStyle(Color.cyan)
                .padding(.top, 24)
            
            Form {
                Section("Name") {
                    TextField("New name", text: $name.max(SizeConstraints.name))
                        .font(.title3.weight(.medium))
                        .focused($focusState, equals: .name)
                        .onSubmit {
                            self.focusState = .details
                        }
                }
                Section("Details") {
                    TextField("New details", text: $details.max(SizeConstraints.details), axis: .vertical)
                        .font(.title3.weight(.light))
                        .focused($focusState, equals: .details)
                        .lineLimit(3, reservesSpace: true)
                        .onChange(of: details) { _, _ in
                            if self.details.last == "\n" {
                                self.details = String(self.details.dropLast()).trimmingSpaces
                                self.focusState = nil
                            }
                        }
                }
            }
            .autocorrectionDisabled()
            .scrollDisabled(true)
            .frame(height: 250)
            .onAppear {
                self.focusState = .name
            }
            .roundClipped()
            
            buttonsStack
            
            Spacer()
        }
    }
}

// MARK: - Controls
fileprivate extension NewListOrBlueprintView {
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
                try createEntityInstante()
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

// MARK: - SwiftData
fileprivate extension NewListOrBlueprintView {
    var isUniqueName: Bool {
        switch entity {
            case .toDoList: lists.first { $0.name.trimLowcaseEquals(name) } == nil
            case.blueprint: blueprints.first { $0.name.trimLowcaseEquals(name) } == nil
        }
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func createEntityInstante() throws {
        switch entity {
            case .toDoList:
                let newList = ToDoList(name: name.trimmingSpaces, details: details.trimmingSpaces)
                modelContext.insert(newList)
            case .blueprint:
                let newBlueprint = Blueprint(name: name.trimmingSpaces, details: details.trimmingSpaces)
                modelContext.insert(newBlueprint)
        }
        
        try modelContext.save()
    }
    
    func save(blueprint: Blueprint) {
        
    }
    
    func save(list: ToDoList) {
        
    }
}

// MARK: - EntityType
extension NewListOrBlueprintView {
    enum Entity {
        case toDoList
        case blueprint
        
        var creteNewTitle: String {
            return switch self {
                case .toDoList: "New ToDo List"
                case .blueprint: "New List Blueprint"
            }
        }
    }
}

// MARK: - Private
private extension NewListOrBlueprintView {
    enum Field: Hashable {
        case name
        case details
    }
}
