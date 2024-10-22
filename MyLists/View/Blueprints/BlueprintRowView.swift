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
                    if blueprint.items.isEmpty {
                        Text("Empty")
                    } else {
                        Text("\(blueprint.items.count) items")
                    }
                }
                .font(.callout.weight(.light)).opacity(0.725)
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .foregroundStyle(Color.cyan)
    }
}
