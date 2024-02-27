//
//  BlueprintRowView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 26/02/2024.
//

import SwiftUI

struct BlueprintRowView: View {
    var blueprint: Blueprint
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(blueprint.name)
                    .font(.title3)
                    .fontWeight(.medium)
            }
            Spacer()
        }
    }
}
