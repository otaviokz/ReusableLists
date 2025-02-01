//
//  SetSortView.swift
//  ReusableLists
//
//  Created by okz on 01/02/25.
//

import SwiftUI

struct SetToDoItemSortView: View {
    @Environment(\.dismiss) private var dismiss
    let currentSortType: SortType
    let onSelect: (SortType) -> Void
        
    init(currentSortType: SortType, onSelect: @escaping (SortType) -> Void) {
        self.currentSortType = currentSortType
        self.onSelect = onSelect
    }
    
    var body: some View {
        List {
            Section("Sort by:") {
                sortOption("Todo first:", icon: .checkBox, sortyType: .doneLast)
                sortOption("Alphabetically:", icon: .az, sortyType: .alphabetic)
                sortOption("Done first:", icon: .checkBoxTicked, sortyType: .doneFirst)
            }
            .font(.headline)
        }
        .presentationDetents([.fraction(0.35)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - UI

private extension SetToDoItemSortView {
    func sortOption(_ label: String, icon: Image, sortyType: SortType) -> some View {
        HStack {
            icon.sizedToFitSquare()
            Spacer().frame(width: 12)
            Text(label).font(.headline)
            Spacer()
            if self.currentSortType == sortyType {
                Image.checkMark
            }
        }
        // It needs to specify content shape to cover all area, since by default only opaque views handle gesture
        // https://stackoverflow.com/a/62640126/884744
        .contentShape(Rectangle())
        .foregroundStyle(Color.cyan)
        .onTapGesture {
            dismiss()
            Task {
                try await Task.sleep(nanoseconds: WaitTimes.dismiss)
            }
            onSelect(sortyType)
        }
    }
}

#Preview {
    SetToDoItemSortView(currentSortType: .alphabetic) {_ in }
}
