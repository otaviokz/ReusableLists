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
        List {
            ForEach(lists) { list in
                NavigationLink(
                    destination: ToDoListItemsView(for: list, action: {_ in delete(list: list, waitFotDimiss: true) })
                ) {
                    listRow(for: list)
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
    // List rows are not created as proper ToDoListRowViews because it stops the completion gauge from updating
    func listRow(for list: ToDoList) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(list.name).font(.title3.weight(.medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                HStack(spacing: 0) {
                    if !list.items.isEmpty && list.doneItems.count != list.items.count {
                        Text("☑").font(.headline.weight(.regular))
                        Text(": \(list.doneItems.count) of \(list.items.count)")
                    } else if !list.items.isEmpty {
                        Text("✓ ").font(.headline.weight(.semibold))
                        Text("Complete")
                    } else {
                        Text("Empty")
                    }
                }
                .font(.callout.weight(.light))
            }
            
            Spacer()
            
            if !list.items.isEmpty {
                gaugeView(list: list)
            }
        }
        .foregroundStyle(Color.cyan)
    }
    
    func gaugeView(list: ToDoList) -> some View {
        Gauge(value: list.completion, in: 0...Double(1)) {
            if list.completion < 1 {
                Text("\(NumberFormatter.noDecimals.string(from: NSNumber(value: list.completion * 100)) ?? "0")%")
                    .font(.body)
            } else {
                Image.checkMark
                    .sizedToFitSquare(side: 16)
                    .foregroundColor(.cyan)
            }
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .scaleEffect(CGSize(width: 0.7, height: 0.7))
        .tint(.cyan)
    }
    
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
                    try await Task.sleep(nanoseconds: 450_000_000)
                }
                try withAnimation(.easeIn(duration: 0.25)) {
                    modelContext.delete(list)
                    listToDelete = .placeholderList
                    try modelContext.save()
                }
            } catch {
                    presentErrorAlert = true
            }
        }
    }
    
    func didDeleteList(list: ToDoList) {
        Task {
            do {
                try await Task.sleep(nanoseconds: 450_000_000)
                try withAnimation {
                    modelContext.delete(list)
                    try modelContext.save()
                }
            } catch {
                presentErrorAlert = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        ToDoListsView()
    }
}
