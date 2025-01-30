//
//  EditItemFormView.swift
//  ReusableLists
//
//  Created by okz on 30/01/25.
//

import SwiftData
import SwiftUI

struct EditItemFormView: View {
    @State var item: ToDoItem
    var onDone: (ToDoItem) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
        }
    }
}

// MARK: - UI
private extension EditItemFormView {
    var headerView: some View {
        HStack {
            Image.todolist
            Text(newItemForEntity.name).font(.title3)
        }
    }
}
