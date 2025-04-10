//
//  GaugeAndPriorityListHeaderView.swift
//  ReusableLists
//
//  Created by okz on 11/02/25.
//

import SwiftUI

struct GaugeAndPriorityListHeaderView: View {
    @ObservedObject var list: ToDoList
    
    var body: some View {
            Gauge(value: list.completion) { }
            .animation(.interpolatingSpring(duration: 0.25, bounce: 0.1, initialVelocity: 0.5), value: list.completion)
                .tint(list.priority ? .red : .green)
                .padding(.horizontal, 22)
    }
}

#Preview {
    GaugeAndPriorityListHeaderView(list: ToDoList())
}


extension Array where Element == ToDoItem {
    
}
    
