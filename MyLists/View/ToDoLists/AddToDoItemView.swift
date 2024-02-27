//
//  EditItemView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI

struct AddToDoItemView: View {
    enum Field: Hashable {
        case name
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    var list: ToDoList
    @State var itemName: String = ""
    @State var itemPriority: Priority = .low
    @State var itemDone: Bool = false
    @FocusState private var focusState: Field?
    
    init(_ list: ToDoList) {
        self.list = list
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
            
            HStack {
                Text("Done")
                Spacer()
                Image(systemName: itemDone ? "checkmark.square" : "square")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        itemDone.toggle()
                    }
            }
        }
        .toolbar {
            Button("Save") {
                let item = ToDoItem(name: itemName.trimmingSpaces, priority: itemPriority, done: itemDone)
                list.items.append(item)
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(isSaveButtonDisabled)
        }
        .onAppear {
            focusState = .name
        }
    }
}

private extension AddToDoItemView {
    var isSaveButtonDisabled: Bool {
        list.items.first { $0.name.trimmingSpacesLowercasedEquals(itemName) } != nil || itemName.trimmingSpaces.isEmpty
    }
}

#Preview {
    let list = ToDoList(name: "Groceries list")
    
    return NavigationStack {
        AddToDoItemView(list)
    }
}
