//
//  ContentView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            ToDoListsView()
                .onAppear {
                    if modelContext.undoManager == nil {
                        modelContext.undoManager = UndoManager()
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
