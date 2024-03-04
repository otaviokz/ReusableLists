//
//  NewBlueprintView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import SwiftUI
import SwiftData

struct NewBlueprintView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @Query private var blueprints: [Blueprint]
    var blueprint: Blueprint?
    @State var name: String = ""
    @State var details: String = ""
    @FocusState private var focusState: Field?
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
                .font(.title3)
                .focused($focusState, equals: .name)
                .onSubmit {
                    focusState = .details
                }
            
            TextField("Details", text: $details, axis: .vertical)
                .lineLimit(1...5)
                .font(.body.weight(.light))
                .focused($focusState, equals: .details)
                .onSubmit {
                    if canSave {
                        saveBlueprint()
                    }
                }
        }
        .navigationTitle("Create Blueprint")
        .toolbar {
            Button("Save", action: saveBlueprint)
                .disabled(!canSave)
        }
        .onAppear {
            focusState = .name
        }
    }
}

private extension NewBlueprintView {
    enum Field: Hashable {
        case name
        case details
        case none
    }
    
    var isUniqueName: Bool {
        let equalNameBlueprints = blueprints.filter {
            $0.name.trimmingSpacesLowercasedEquals(name)
        }
        return equalNameBlueprints.isEmpty || equalNameBlueprints == [blueprint]
    }
    
    func saveBlueprint() {
        let blueprint = Blueprint(name: name.trimmingSpaces, details: details.trimmingSpaces)
        modelContext.insert(blueprint)
        try? modelContext.save()
        presentationMode.wrappedValue.dismiss()
    }
    
    var canSave: Bool {
        !name.trimmingSpaces.isEmpty && isUniqueName
    }
}

#Preview {
    NewBlueprintView()
}
