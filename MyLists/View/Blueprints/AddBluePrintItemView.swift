//
//  AddBlueprintItemView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import SwiftUI



struct AddBlueprintItemView: SheetWrappedViewable {
    @Environment(\.modelContext) private var modelContext
   
    @State private var name: String = ""
    @State private var showAlert = false
    @State var isSheetPresented: Binding<Bool>
    @FocusState private var focusState: Field?
    let Blueprint: Blueprint
    
    init(_ Blueprint: Blueprint, isSheetPresented: Binding<Bool>) {
        self.Blueprint = Blueprint
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("New item for \(Blueprint.name)")
                .font(.title2)
                .foregroundStyle(Color.cyan)
                .padding(.top, 24)
            
            Form {
                Section("New Item") {
                    TextField("Name", text: $name.max(SizeConstraints.name))
                        .font(.title3)
                        .focused($focusState, equals: .name)
                        .onSubmit {
                            focusState = nil
                        }
                }
            }
            .frame(height: 112)
            .roundClipped()
            
            buttonsStack
            
            Spacer()
        }
        .onAppear {
            focusState = .name
        }
    }
}

fileprivate extension AddBlueprintItemView {
    enum Field: Hashable {
        case name
    }
    
    var isUniqueName: Bool {
        Blueprint.items.first { $0.name == name } == nil
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func saveBlueprintItem() throws {
        let item = BlueprintItem(name: name.trimmingSpaces)
        modelContext.insert(item)
        Blueprint.items.append(item)
        try modelContext.save()
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
        .autocorrectionDisabled()
        .font(.title2)
        
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

#Preview {
    @Previewable @State var isSheetPresented = true
    NavigationStack {
        VStack {
            
        }
        .navigationTitle("Add ")
    }
    .sheet(isPresented: $isSheetPresented) {
        AddBlueprintItemView(Blueprint(name: "Groceries"), isSheetPresented: $isSheetPresented)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
    }
}
