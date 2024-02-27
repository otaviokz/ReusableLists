//
//  AddBluePrintItemView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 27/02/2024.
//

import SwiftUI

struct AddBluePrintItemView: View {
    enum Field: Hashable {
        case name
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    var blueprint: Blueprint
    @State var itemName: String = ""
    @State var itemPriority: Priority = .low
    @FocusState private var focusState: Field?
    
    init(_ blueprint: Blueprint) {
        self.blueprint = blueprint
    }
    
    var body: some View {
        Form {
            TextField("Name", text: $itemName)
                .font(.title3)
                .focused($focusState, equals: .name)
                .onSubmit {
                    focusState = nil
                }
            
            Section {
                Picker("Priority", selection: $itemPriority) {
                    Text("Low")
                        .foregroundColor(Priority.low.color)
                        .tag(Priority.low)
                    Text("Medium")
                        .foregroundColor(Priority.medium.color)
                        .tag(Priority.medium)
                    Text("High")
                        .foregroundColor(Priority.high.color)
                        .tag(Priority.high)
                }
                .fontWeight(.bold)
                .pickerStyle(.inline)
            }
        }
        .toolbar {
            Button("Save") {
                let item = BlueprintItem(name: itemName.trimmingSpaces, priority: itemPriority)
                blueprint.items.append(item)
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(isSaveButtonDisabled)
        }
        .onAppear {
            focusState = .name
        }
    }
}

private extension AddBluePrintItemView {
    var isSaveButtonDisabled: Bool {
        blueprint.items.first {
            $0.name.trimmingSpacesLowercasedEquals(itemName)
        } != nil || itemName.trimmingSpaces.isEmpty
    }
}

#Preview {
    AddBluePrintItemView(Blueprint(name: "Groceries"))
}
