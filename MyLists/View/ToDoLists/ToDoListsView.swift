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
    @State private var listToDelete = ToDoList.placeholderList
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
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
                            showingDeleteAlert = true
                        }
                        .tint(.red)
                    }
                }
                .confirmationDialog(deleteConfirmationText, isPresented: $showingDeleteAlert, titleVisibility: .visible) {
                    Button(role: .destructive) {
                        delete(list: listToDelete)
                    } label: {
                        Text("Delete").foregroundStyle(Color.red)
                    }
                    
                    Button("Cancel", role: .cancel) { showingDeleteAlert = false }
                }
            }
            .scrollIndicators(.hidden)
//            .toolbar {
//                Image.plus
//                    .padding(.trailing, 4)
//                    .onTapGesture { presentAddToDoListSheet = true }
//                    .foregroundStyle(Color.cyan)
//                    .accessibilityIdentifier("plus")
//            }
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
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .onTapGesture { presentAddToDoListSheet = true }
                        .foregroundStyle(Color.cyan)
                        .accessibilityIdentifier("plus")
                }
                
            }.padding(.bottom, 24)
                .padding(.trailing, 16)
        }
    }
}
    // MARK: - UI
    
    extension ToDoListsView {
        var deleteConfirmationText: Text {
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
                        listToDelete = .placeholderList
                        try modelContext.save()
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
