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
    @State private var showErrorAlert = false
    @State private var errorAlertMessage = Alert.defaultErrorMessage
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
            .frame(height: 256)
            .alert(isPresented: $showErrorAlert) {
                Alert.genericErrorAlert
            }
            .onAppear {
                self.focusState = .name
            }
            .roundClipped()
            
            buttonsStack
            
            Spacer()
        }
    }
}

// MARK: - UI

fileprivate extension NewListOrBlueprintView {
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
        Button { createEntityInstanteAndDismissSheet() } label: { Text("Save") }
            .disabled(isSaveButtonDisabled)
    }
    
    var exitButton: some View {
        Button { dismissSheet() } label: { Text("Exit") }
    }
}

// MARK: - SwiftData

fileprivate extension NewListOrBlueprintView {
    var isUniqueName: Bool {
        switch entity {
            case .toDoList:
                lists.first { $0.name.trimLowcaseEquals(name) } == nil
            case.blueprint:
                blueprints.first { $0.name.trimLowcaseEquals(name) } == nil
        }
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func createEntityInstanteAndDismissSheet() {
        switch entity {
            case .toDoList:
                let newList = ToDoList(name: name.trimmingSpaces, details: details.trimmingSpaces)
                modelContext.insert(newList)
            case .blueprint:
                let newBlueprint = Blueprint(name: name.trimmingSpaces, details: details.trimmingSpaces)
                modelContext.insert(newBlueprint)
        }
        errorAlertMessage = Alert.defaultErrorMessage
        do {
            try modelContext.save()
            dismissSheet()
        } catch let error as ListError {
            switch error as ListError {
                case .listNameUnavailable(_), .blueprintNameUnavailable(_):
                    errorAlertMessage = error.message
                default: break
            }
            showErrorAlert = true
        } catch {
            showErrorAlert = true
        }
    }
}

// MARK: - EntityType
extension NewListOrBlueprintView {
    enum Entity {
        case toDoList
        case blueprint
        
        var creteNewTitle: String {
            return switch self {
                case .toDoList: "New ToDoList"
                case .blueprint: "New List Blueprint"
            }
        }
    }
}

