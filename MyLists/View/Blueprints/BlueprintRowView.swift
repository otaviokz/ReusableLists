//
//  BlueprintRowView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 26/02/2024.
//

import SwiftUI

struct BlueprintRowView: View {
    let blueprint: Blueprint
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(blueprint.name)
                    .font(.title3.weight(.medium))
                   
                Group {
                    if blueprint.items.isEmpty {
                        Text("Empty")
                            .font(.callout.weight(.light))
                    } else {
                        Text("\(blueprint.items.count) items")
                            .font(.callout.weight(.light))
                    }
                }
                
            }
            Spacer()
        }
        .foregroundStyle(Color.cyan)
    }
}
