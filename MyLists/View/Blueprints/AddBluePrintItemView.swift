//
//  AddBluePrintItemView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import SwiftUI



struct AddBluePrintItemView: SheetWrappedViewable {
    @Environment(\.modelContext) private var modelContext
    @State private var name: String = ""
    @State private var itemPriority: Priority = .low
    @State private var showAlert = false
    @State var isSheetPresented: Binding<Bool>
    @FocusState private var focusState: Field?
    let blueprint: Blueprint
    
    init(_ blueprint: Blueprint, isSheetPresented: Binding<Bool>) {
        self.blueprint = blueprint
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 32) {
                Form {
                    Section("New Item") {
                        TextField("Name", text: $name.max(BlueprintItem.nameSizeLimit))
                            .font(.title3)
                            .focused($focusState, equals: .name)
                            .onSubmit {
                                focusState = nil
                            }
                    }
                    .onAppear {
                        focusState = .name
                    }
                }
                .frame(height: 112)
                .roundClipped()
                
                HStack {
                    Spacer()
                    exitButton
                    Spacer()
                    if !isSaveButtonDisabled {
                        saveButton
                        Spacer()
                    }
                }
                
                Spacer()
            }
        }
    }
}

fileprivate extension AddBluePrintItemView {
    enum Field: Hashable {
        case name
    }
    
    var isUniqueName: Bool {
        blueprint.items.first { $0.name == name } == nil
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func saveBlueprintItem() throws {
        let item = BlueprintItem(name: name.trimmingSpaces)
        modelContext.insert(item)
        blueprint.items.append(item)
        try modelContext.save()
    }
    
    var saveButton: some View {
        Button {
            do {
                try saveBlueprintItem()
                dismissSheet()
            } catch {
                showAlert = true
            }
        } label: {
            Text("Save")
                .font(.title2)
        }
        .foregroundStyle(Color.cyan.opacity(isSaveButtonDisabled ? 0 : 1))
        .disabled(isSaveButtonDisabled)
        .padding(.top, 12)
        .alert(isPresented: $showAlert) {
            Alert.genericErrorAlert
        }
    }
    
    var exitButton: some View {
        Button {
            dismissSheet()
        } label: {
            Text("Exit").font(.title2)
        }
        .foregroundStyle(Color.cyan)
//        .disabled(isSaveButtonDisabled)
        .padding(.top, 12)
    }
}

#Preview {
    @Previewable @State var isSheetPresented = true
    NavigationStack {
        VStack {
            
        }
        .navigationTitle("Add ")
    }
    .sheet(isPresented: $isSheetPresented) {
        AddBluePrintItemView(Blueprint(name: "Groceries"), isSheetPresented: $isSheetPresented)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
    }
}
