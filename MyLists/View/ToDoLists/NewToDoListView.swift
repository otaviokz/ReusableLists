//
//  EditListView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

struct NewToDoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @Query private var lists: [ToDoList]
    var list: ToDoList?
    @State var name: String = ""
    @State var details: String = ""
    @FocusState private var focusState: Field?
    
    init() {}
    
    var body: some View {
        Form {
            Section {
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
                            saveList()
                        }
                    }
            }
        }
        .navigationTitle("Create List")
        .toolbar {
            Button("Save", action: saveList)
                .disabled(!canSave)
        }
        .onAppear {
            focusState = .name
        }
    }
}

private extension NewToDoListView {
    enum Field: Hashable {
        case name
        case details
    }
    
    var isUniqueName: Bool {
        let equalNameLists = lists.filter {
            $0.name.trimmingSpacesLowercasedEquals(name)
        }
        return equalNameLists.isEmpty || equalNameLists == [list]
    }
    
    func saveList() {
        let list = ToDoList(name: name.trimmingSpaces, details: details.trimmingSpaces)
        modelContext.insert(list)
        presentationMode.wrappedValue.dismiss()
    }
    
    var canSave: Bool {
        !name.trimmingSpaces.isEmpty && isUniqueName
    }
}

#Preview {
    NavigationStack {
        NewToDoListView()
    }
}
