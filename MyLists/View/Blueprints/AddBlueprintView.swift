//
//  AddBlueprintView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import SwiftUI
import SwiftData

struct AddBlueprintView: SheetWrappedViewable {
    @Environment(\.modelContext) private var modelContext
//    @EnvironmentObject var tabSelection: TabSelection
    
    @Query private var blueprints: [Blueprint]
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var details: String = ""
    @State private var showAlert = false
    @State var isSheetPresented: Binding<Bool>
    private var blueprint: Blueprint?
    
    init(isSheetPresented: Binding<Bool>) {
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack {
            Form(){
                Section("Name") {
                    TextField("New name", text: $name.max(Blueprint.nameSizeLimit))
                        .font(.title3.weight(.medium))
                        .focused($focusState, equals: .name)
                        .onSubmit {
                            focusState = .details
                        }
                }
                Section("Details") {
                    TextField("New details", text: $details.max(Blueprint.detailsSizeLimit), axis: .vertical)
                        .font(.title3.weight(.light))
                        .focused($focusState, equals: .details)
                        .lineLimit(2, reservesSpace: true)
                        .onChange(of: details) { _, _ in
                            if details.last == "\n" {
                                details = String(details.dropLast()).trimmingSpaces
                                focusState = nil
                            }
                        }
                }
            }
            .scrollDisabled(true)
            .frame(height: 260)
            .onAppear {
                focusState = .name
            }
            .roundClipped()
            
            Button {
                do {
                    try saveBlueprint()
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
            
            Spacer()
        }
    }
}

fileprivate extension AddBlueprintView {
    enum Field: Hashable {
        case name
        case details
        case none
    }
    
    var isUniqueName: Bool {
        blueprints.first { $0.name.trimmingSpacesLowercasedEquals(name) } == nil
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func saveBlueprint() throws {
        let blueprint = Blueprint(name: name.trimmingSpaces, details: details.trimmingSpaces)
        modelContext.insert(blueprint)
        try modelContext.save()
    }
}

#Preview {
    @Previewable @State var isSheetPresented = true
    AddBlueprintView(isSheetPresented: $isSheetPresented)
}
