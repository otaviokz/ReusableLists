//
//  AddListOrBlueprintView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 26/09/2024.
//

import SwiftUI
import SwiftData

struct AddListOrBlueprintView: SheetWrappedViewable {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var blueprints: [Blueprint]
    @Query private var lists: [ToDoList]
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var details: String = ""
    @State private var presentAlert = false
    @State private var errorMessage = Alert.genericErrorMessage
    @State var isSheetPresented: Binding<Bool>
    var entity: ListEntity
    
    init(isSheetPresented: Binding<Bool>, entity: ListEntity) {
        self.isSheetPresented = isSheetPresented
        self.entity = entity
    }
    
    var body: some View {
        VStack(spacing: 16) {
            headerView
            formView
            Spacer()
            buttonsStack
                .padding(.bottom, Sizes.exitOrSaveBottomPadding)
        }
        .alert(isPresented: $presentAlert) {
            Alert.genericError
        }
        .onAppear {
            focusState = .name
        }
        .foregroundStyle(Color.cyan)
    }
}

// MARK: - UI

fileprivate extension AddListOrBlueprintView {
    enum Field: Hashable {
        case name
        case details
    }
    
    var headerView: some View {
        HStack(spacing: 8) {
            entity.headerImage
                .sizedToFitHeight(22)
                .padding(.trailing, entity.addEntityTitleImageRightPadding)
            
            Text("New \(entity.rawValue)")
                .font(.title2.weight(.light))
        }
        .foregroundStyle(Color.cyan)
        .padding(.top, 24)
    }
    
    var formView: some View {
        Form {
            Section("\(entity.rawValue) Fields:") {
                Group {
                    TextField(
                        "Name (max \(DataFieldsSizeLimit.name) characters)",
                        text: $name.max(DataFieldsSizeLimit.name)
                    )
                    .font(.title3)
                    .focused($focusState, equals: .name)
                    .onSubmit { focusState = .details }
                    
                    TextField(
                        "Details (optional, max \(DataFieldsSizeLimit.details) characters)",
                        text: $details.max(DataFieldsSizeLimit.details),
                        axis: .vertical
                    )
                    .font(.headline.weight(.light))
                    .focused($focusState, equals: .details)
                    .lineLimit(SizeConstraints.detailsFieldLineLimit, reservesSpace: true)
                    .onChange(of: details) { _, _ in
                        if details.last == "\n" {
                            details = String(self.details.dropLast()).asInput
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
        .roundClipped()
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
        Button { createEntityInstanteAndDismissSheet() } label: { Text("Save") }
            .disabled(isSaveButtonDisabled)
    }
    
    var exitButton: some View {
        Button { dismissSheet() } label: { Text("Exit") }
    }
}

// MARK: - SwiftData

fileprivate extension AddListOrBlueprintView {
    var isUniqueName: Bool {
        switch entity {
            case .toDoList: lists.first { $0.name.trimLowcaseEquals(name) } == nil
            case .blueprint: blueprints.first { $0.name.trimLowcaseEquals(name) } == nil
        }
    }
    
    var isSaveButtonDisabled: Bool {
        name.asInput.isEmpty || !isUniqueName
    }
    
    func createEntityInstanteAndDismissSheet() {
        dismissSheet()
        Task {
            do {
                try await Task.sleep(nanoseconds: WaitTimes.insertOrRemove)
                try withAnimation(.easeIn(duration: 0.25)) {
                    switch (entity, name.asInput, details.asInput) {
                        case (.toDoList, let name, let details):
                            modelContext.insert(ToDoList(name, details: details))
                        case (.blueprint, let name, let details):
                            modelContext.insert(Blueprint(name, details: details))
                    }
                    
                    try modelContext.save()
                }
            } catch {
                logger.error("Error createEntityInstanteAndDismissSheet(): \(error)")
                handleSaveError(error)
            }
        }
        
        func handleSaveError(_ error: Error) {
            errorMessage = Alert.genericErrorMessage
            if let listError = error as? ListError {
                errorMessage = switch listError {
                    case .listNameUnavailable, .blueprintNameUnavailable: listError.message
                    default: errorMessage
                }
            }
            presentAlert = true
        }
    }
}
