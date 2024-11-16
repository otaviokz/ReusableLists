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
    @State private var presentErrorAlert = false
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
                            delete(list: list, waitFotDimiss: true)
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
                deleteConfirmationText,
                isPresented: $presentDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(role: .destructive) {
                    guard let listToDelete = listToDelete else { return }
                    delete(list: listToDelete, waitFotDimiss: false)
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
        .alert(isPresented: $presentErrorAlert) {
            Alert.genericError
        }
        .sheet(isPresented: $presentAddToDoListSheet) {
            AddListOrBlueprintView(isSheetPresented: $presentAddToDoListSheet, entity: .toDoList)
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

extension ToDoListsView {
    var deleteConfirmationText: Text {
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
    func delete(list: ToDoList, waitFotDimiss: Bool = true) {
        Task {
            do {
                if waitFotDimiss {
                    try await Task.sleep(nanoseconds: WaitTimes.insertOrRemove)
                }
                
                try withAnimation(.easeIn(duration: 0.25)) {
                    modelContext.delete(list)
                    try modelContext.save()
                    listToDelete = nil
                }
            } catch {
                presentErrorAlert = true
                logger.error("Error deleting ToDoList: \(error)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ToDoListsView()
    }
}
