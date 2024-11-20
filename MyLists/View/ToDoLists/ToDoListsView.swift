//
//  ListsView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI
import SwiftData

struct ToDoListsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var tabselection: TabSelection
    
    @Query(sort: [SortDescriptor(\ToDoList.name, order: .forward)])
    private var lists: [ToDoList]
    @State private var presentAlert = false
    @State private var alertMessage: String = Alert.genericErrorMessage
    @State private var presentAddToDoListSheet = false
    @State private var listToDelete: ToDoList?
    @State private var presentDeleteConfirmation = false
    
    var body: some View {
        List {
            ForEach(lists) { list in
                NavigationLink(
                    destination: ToDoListItemsView(
                        for: list,
                        allDoneAction: {_ in
                            delete(list: list, waitFotItemsViewDimiss: true)
                        }
                    )
                ) {
                    ToDoListRowView(list: list)
                }
                .swipeActions {
                    Button("Delete", role: .cancel) {
                        listToDelete = list
                        presentDeleteConfirmation = true
                    }
                    .tint(.red)
                }
            }
            .confirmationDialog(
                deleteConfirmationDialogTitle,
                isPresented: $presentDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(role: .destructive) {
                    guard let listToDelete = listToDelete else { return }
                    delete(list: listToDelete, waitFotItemsViewDimiss: false)
                } label: {
                    Text("Delete").foregroundStyle(Color.red)
                }
                
                Button("Cancel", role: .cancel) { presentDeleteConfirmation = false }
            }
        }
        .animation(.linear(duration: 0.25), value: lists)
        .scrollIndicators(.hidden)
        .toolbar {
            Image.plus
                .padding(.trailing, 4)
                .onTapGesture { presentAddToDoListSheet = true }
                .foregroundStyle(Color.cyan)
                .accessibilityIdentifier("plus")
        }
        .alert(isPresented: $presentAlert) {
            Alert.genericError
        }
        .sheet(isPresented: $presentAddToDoListSheet) {
            NewListOrBlueprintFormView(
                isSheetPresented: $presentAddToDoListSheet,
                entity: .toDoList,
                isUniqueName: isUniqueName,
                createEntity: createNewEntity,
                handleSaveError: handleSaveError
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .task {
            if tabselection.selectedTab == 1 && tabselection.shouldPopToRootView {
                tabselection.didPopToRootView()
            }
        }
        .navigationTitle("Lists")
    }
}

// MARK: - UI

private extension ToDoListsView {
    var deleteConfirmationDialogTitle: Text {
        guard let listToDelete = listToDelete else { return Text("") }
        var message = "List \"\(listToDelete.name)\""
        if !listToDelete.items.isEmpty {
            message += " and it's \(listToDelete.items.count) items"
        }
        message += " will be deleted."
        return Text(message)
    }
}

// MARK: - SwiftData

private extension ToDoListsView {
    func delete(list: ToDoList, waitFotItemsViewDimiss: Bool) {
        Task {
            do {
                if waitFotItemsViewDimiss {
                    try await Task.sleep(nanoseconds: WaitTimes.sheetDismissAndInsertOrRemove)
                }
                
                try withAnimation(.easeIn(duration: 0.25)) {
                    modelContext.delete(list)
                    try modelContext.save()
                    listToDelete = nil
                }
            } catch {
                presentAlert = true
                logger.error("Error deleting ToDoList: \(error)")
            }
        }
    }
}

extension ToDoListsView: NewEntityCreatorProtocol {
    func insertEntity(name: String, details: String) throws {
        modelContext.insert(ToDoList(name, details: details))
        try modelContext.save()
    }
    
    func isUniqueName(name: String) -> Bool {
        lists.first { $0.name.asInputLowercasedEquals(name) } == nil
    }
    
    func handleSaveError(error: Error, name: String) {
        logger.error("Error createNewEntity(ToDoList): \(error)")
        alertMessage = Alert.genericErrorMessage
        if case ListError.listNameUnavailable = error {
            alertMessage = ListError.listNameUnavailable(name: name).message
        }
        presentAlert = true
    }
}

#Preview {
    NavigationStack {
        ToDoListsView()
    }
}
