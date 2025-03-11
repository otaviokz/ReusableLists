//
//  ToDoListRowView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 19/10/2024.
//

import SwiftUI

struct ToDoListRowView: View {
    let list: ToDoList
    @State private var items: [ToDoItem] = []
    
    var body: some View {
        HStack(spacing: 6) {
            if !items.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    if !items.isEmpty {
                        
                        titleText
                        
                        HStack(alignment: .center, spacing: 0) {
                            if list.priority {
                                priorityImage
                            }
                            
                            if !items.isEmpty && items.doneItems.count != items.count {
                                Text("☑").font(.title2.weight(.light))
                                Text(": ").font(.title3.weight(.light))
                                    .padding(.bottom, 4)
                                Text("\(items.doneItems.count) of \(items.count)")
                            } else if !items.isEmpty {
                                Text("✓ ").font(.title3.weight(.light))
                                Text("Complete")
                            }
                        }
                        .font(.callout.weight(.light)).opacity(0.725)
                    }
                }
            } else {
                titleText
                
                if list.priority {
                    Spacer()
                    priorityImage
                        .opacity(0.6)
                }
            }
            
            if !items.isEmpty && !items.doneItems.isEmpty {
                Spacer()
                gaugeView(list: list)
                    .frame(alignment: .trailing)
            }
        }
        .layoutPriority(1000)
        .frame(maxWidth: .infinity, alignment: .leading)
        // It needs to specify content shape to cover all area, since by default only opaque views handle gesture
        // https://stackoverflow.com/a/62640126/884744
        .contentShape(Rectangle())
        .foregroundStyle(Color.cyan)
        .onAppear {
            items = list.items
        }
        .navigationBarBackButtonHidden(false)
    }
}

// MARK: - UI

private extension ToDoListRowView {
    func gaugeView(list: ToDoList) -> some View {
        Gauge(value: list.completion, in: 0...Double(1)) {
            if list.completion < 1 {
                Text("\(NumberFormatter.noDecimals.string(from: NSNumber(value: list.completion * 100)) ?? "0")%")
                    .font(.body)
            } else {
                Image.checkMark
                    .sizedToFitSquare(side: 16)
                    .foregroundColor(.cyan)
            }
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .scaleEffect(CGSize(width: 0.7, height: 0.7))
        .tint(.cyan)
    }
    
    var titleText: some View {
        Text(list.name)
            .font(.title3.weight(.medium))
            .padding(.top, items.isEmpty ? 7 : 0)
            .padding(.bottom, items.isEmpty ? 7.5 : 0)
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    var priorityImage: some View {
        let size: CGFloat = items.isEmpty ? 24 : 16
        return Image
            .priority
            .sizedToFitSquare(side:size)
            .foregroundStyle(Color.red)
            .fontWeight(.semibold)
            .padding(.trailing, 6)
            .frame(alignment: .trailing)
    }
}

#Preview {
    ToDoListRowView(list: ToDoList("Sample list", details: ""))
        .padding()
}
