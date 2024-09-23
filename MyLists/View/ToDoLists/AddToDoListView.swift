//
//  AddToDoListView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

struct AddToDoListView: SheetWrappedViewable {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var lists: [ToDoList]
    @FocusState private var focusState: Field?
    @State var name: String = ""
    @State var details: String = ""
    @State private var showAlert = false
    @State var isSheetPresented: Binding<Bool>
    var list: ToDoList?
    
    init(isSheetPresented: Binding<Bool>) {
        self.isSheetPresented = isSheetPresented
    }
    
    var body: some View {
        VStack {
            Form {
                Section("Name") {
                    TextField("New name", text: $name.max(ToDoList.nameSizeLimit))
                        .font(.title3.weight(.medium))
                        .focused($focusState, equals: .name)
                        .onSubmit {
                            focusState = .details
                        }
                }
                Section("Details") {
                    TextField("New details", text: $details.max(ToDoList.detailsSizeLimit), axis: .vertical)
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
                    try saveList()
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

private extension AddToDoListView {
    enum Field: Hashable {
        case name
        case details
    }
    
    var isUniqueName: Bool {
        lists.first {
            $0.name.trimmingSpacesLowercasedEquals(name)
        } == nil
    }
    
    var isSaveButtonDisabled: Bool {
        name.trimmingSpaces.isEmpty || !isUniqueName
    }
    
    func saveList() throws {
        let list = ToDoList(name: name.trimmingSpaces, details: details.trimmingSpaces)
        modelContext.insert(list)

        try modelContext.save()
    }
}

#Preview {
    @Previewable @State var isSheetPresented = true
    NavigationStack {
        AddToDoListView(isSheetPresented: $isSheetPresented)
    }
}
