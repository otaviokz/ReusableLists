//
//  UpdateBlueprintView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 22/09/2024.
//

import SwiftUI
import SwiftData
import Foundation

struct UpdateBlueprintView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var blueprints: [Blueprint]
    @FocusState private var focusState: Field?
    @State private var name: String = ""
    @State private var details: String = ""
    @State private var showAlert = false
    let blueprint: Blueprint
    
    init(_ blueprint: Blueprint) {
        self.blueprint = blueprint
        name = blueprint.name
        details = blueprint.details
    }
    
    var body: some View {
        VStack {
            Form {
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
                    try saveBluePrint()
                    dismiss()
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
//        .padding(.top, 32)
        .onAppear {
            name = blueprint.name
            details = blueprint.details
        }
        .navigationTitle("Edit \"\(blueprint.name)\"")
    }
}

fileprivate extension UpdateBlueprintView {
    enum Field: Hashable {
        case name
        case details
    }
    
    var isUniqueName: Bool {
        if let sameNameBlueprint: Blueprint = blueprints.first(where: { $0.name.trimmingSpacesLowercasedEquals(name) }) {
            return sameNameBlueprint == blueprint
        }
        return true
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func saveBluePrint() throws {
        blueprint.name = name
        blueprint.details = details
        try modelContext.save()
    }
}

//#Preview {
//    NavigationStack {
//        ToDoListUpdateView(ToDoList(name: "List to be edited", details: "List details"), list: [ToDoList]())
//    }
//}
