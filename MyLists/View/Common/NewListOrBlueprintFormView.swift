//
//  AddListOrBlueprintView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 26/09/2024.
//

import SwiftUI
import SwiftData

struct NewListOrBlueprintFormView: SheetWrappedViewable {
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var details: String = ""
    @State var isSheetPresented: Binding<Bool>
    
    private var entity: ListEntity
    private let isUniqueName: (String) -> Bool
    private let createEntity: (String, String) -> Void
    private let handleSaveError: (Error, String) -> Void
    
    init(isSheetPresented: Binding<Bool>,
         entity: ListEntity,
         isUniqueName: @escaping (String) -> Bool,
         createEntity: @escaping (String, String) -> Void,
         handleSaveError: @escaping (Error, String) -> Void
    ) {
        self.isSheetPresented = isSheetPresented
        self.entity = entity
        self.isUniqueName = isUniqueName
        self.createEntity = createEntity
        self.handleSaveError = handleSaveError
    }
    
    var body: some View {
        VStack(spacing: 16) {
            headerView
            formView
            Spacer()
            buttonsStack
                .padding(.bottom, Sizes.exitOrSaveBottomPadding)
        }
        .onAppear {
            focusState = .name
        }
        .foregroundStyle(Color.cyan)
    }
}

// MARK: - UI

fileprivate extension NewListOrBlueprintFormView {
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
        Button { dismissSheetAndCreateEntity() } label: { Text("Save") }
            .disabled(isSaveButtonDisabled)
    }
    
    var exitButton: some View {
        Button { dismissSheet() } label: { Text("Exit") }
    }
}

// MARK: - SwiftData

fileprivate extension NewListOrBlueprintFormView {
    var isSaveButtonDisabled: Bool {
        name.asInput.isEmpty || !isUniqueName(name.asInput)
    }
    
    func dismissSheetAndCreateEntity() {
        dismissSheet()
        createEntity(name.asInput, details.asInput)
    }
}

#Preview {
    @Previewable @State var isSheetPresented: Bool = false
    NewListOrBlueprintFormView(
        isSheetPresented: $isSheetPresented,
        entity: .toDoList,
        isUniqueName: {_ in true },
        createEntity: { _, _ in },
        handleSaveError: { _, _ in }
    )
}
