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
        HStack{
            Gauge(value: list.completion) { }
                .animation(.linear(duration: 0.25), value: list.completion)
                .tint(.green)
                .padding(list.priority ? .horizontal : .leading, 22)
            
            Image
                .priority
                .sizedToFitSquare(side: 22)
                .foregroundStyle(list.priority == true ? Color.red : Color.disabled)
                .padding(.trailing, 22)
        }
    }
}

#Preview {
    GaugeAndPriorityListHeaderView(list: ToDoList())
}


extension Array where Element == ToDoItem {
    
}
    
