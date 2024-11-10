//
//  BlueprintRowView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 26/02/2024.
//

import SwiftUI

struct BlueprintRowView: View {
    let blueprint: Blueprint
    
    init(_ blueprint: Blueprint) {
        self.blueprint = blueprint
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(blueprint.name)
                    .font(.title3.weight(.medium))
                   
                Group {
                    HStack(spacing: 0) {
                        if blueprint.items.isEmpty {
                            Text("Empty")
                        } else {
                            Text("Items: \(blueprint.items.count)")
                                .frame(alignment: .leading)
                            if blueprint.usageCount > 0 {
                                Text(", Usage: \(blueprint.usageCount)")
                            }
                        }
                    }
                }
                .font(.footnote/*.weight(.light)*/)
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .foregroundStyle(Color.cyan)
    }
}
