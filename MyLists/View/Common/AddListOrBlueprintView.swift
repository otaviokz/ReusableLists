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
    @State private var errorAlertMessage = Alert.gnericErrorMessage
    @State var isSheetPresented: Binding<Bool>
    var listEntity: ListEntity
    
    init(isSheetPresented: Binding<Bool>, entity: ListEntity) {
        self.isSheetPresented = isSheetPresented
        self.listEntity = entity
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                listEntity.headerImage
                    .sizedToFitHeight(22)
                    .padding(.trailing, listEntity.addEntityTitleImageRightPadding)
                
                Text("New \(listEntity.rawValue)")
                    .font(.title2.weight(.light))                    
            }
            .foregroundStyle(Color.cyan)
            .padding(.top, 24)
            
            Form {
                Section("Fields:") {
                    Group {
                        TextField("Name", text: $name.max(SizeConstraints.name))
                            .font(.title3)
                            .focused($focusState, equals: .name)
                            .onSubmit { focusState = .details }
                        
                        TextField("Details (optional)", text: $details.max(SizeConstraints.details), axis: .vertical)
                            .font(.headline.weight(.light))
                            .focused($focusState, equals: .details)
                            .lineLimit(SizeConstraints.detailsFieldLineLimit, reservesSpace: true)
                            .onChange(of: details) { _, _ in
                                if details.last == "\n" {
                                    details = String(self.details.dropLast()).trimmingSpaces
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
        switch listEntity {
            case .toDoList: lists.first { $0.name.trimLowcaseEquals(name) } == nil
            case .blueprint: blueprints.first { $0.name.trimLowcaseEquals(name) } == nil
        }
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func createEntityInstanteAndDismissSheet() {
        dismissSheet()
        
        errorAlertMessage = Alert.gnericErrorMessage
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.25)) {
                switch listEntity {
                    case .toDoList:
                        let newList = ToDoList(name: name.trimmingSpaces, details: details.trimmingSpaces)
                        modelContext.insert(newList)
                    case .blueprint:
                        let newBlueprint = Blueprint(name: name.trimmingSpaces, details: details.trimmingSpaces)
                        modelContext.insert(newBlueprint)
                }
                do {
                    try modelContext.save()
                } catch let error as ListError {
                    switch error as ListError {
                        case .listNameUnavailable, .blueprintNameUnavailable:
                            errorAlertMessage = error.message
                        default: break
                    }
                    presentAlert = true
                } catch {
                    presentAlert = true
                }
            }
        }
    }
}
