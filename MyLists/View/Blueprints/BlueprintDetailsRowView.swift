//
//  BlueprintDetailsRowView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 29/10/2024.
//

import SwiftUI

struct BlueprintDetailsRowView: View {
    let blueprint: Blueprint
    
    var body: some View {
        HStack {
            Text(blueprint.details).font(.title3)
                .foregroundStyle(Color.primary)
        }
    }
}

#Preview {
    List {
        Section("Blueprint Details:") {
            BlueprintDetailsRowView(
                blueprint: Blueprint(
                    "",
                    details:
"""
One morning, when Gregor Samsa woke from troubled dreams, he found himself transformed in his bed into a horrible \
vermin.
"""
                )
            )
        }
    }
    
}
