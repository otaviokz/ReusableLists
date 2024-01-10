//
//  EditListView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

struct AddOrEditListView: View {
    enum Field: Hashable {
        case name
        case details
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @Query private var lists: [ToDoList]
    var list: ToDoList
    @State var listName: String = ""
    @State var listDetails: String = ""
    @FocusState private var focusState: Field?
    
    init(_ list: ToDoList) {
        self.list = list
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $listName)
                    .font(.title3)
                    .focused($focusState, equals: .name)
                    .onSubmit {
                        focusState = .details
                    }
                
                TextField("Details", text: $listDetails, axis: .vertical)
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
        .navigationTitle("Edit List")
        .toolbar {
            Button("Save", action: saveList)
                .disabled(!canSave)
        }
        .onAppear {
            listName = list.name
            listDetails = list.details
            focusState = .name
        }
    }
    
    
}

private extension AddOrEditListView {
    var listUnchanged: Bool {
        listName.trimmingSpaces == list.name &&
        listDetails.trimmingSpaces == list.details
    }
    
    var isUniqueName: Bool {
        let equalNameLists = lists.filter {
            $0.name.trimmingSpacesLowercasedEquals(listName)
        }
        return equalNameLists.isEmpty || equalNameLists == [list]
    }
    
    func saveList() {
        list.name = listName.trimmingSpaces
        list.details = listDetails.trimmingSpaces
        modelContext.insert(list)
        presentationMode.wrappedValue.dismiss()
    }
    
    var canSave: Bool {
        !listName.trimmingSpaces.isEmpty && !listUnchanged && isUniqueName
    }
}

#Preview {
    NavigationStack {
        AddOrEditListView(ToDoList(name: "Sample List"))
    }
}
