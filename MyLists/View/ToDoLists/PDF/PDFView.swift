//
//  PDFView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 30/10/2024.
//

import SwiftUI
import SwiftData
import PDFKit

struct PDFView: View {
    let list: ToDoList
    let items: [ToDoItem]
    let listItems: [ToDoItem] = []
//    let page: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header
//            if page == 1 {
                HStack {
                    Spacer()
                    Image.todolist
                    Text("- \(list.name)")
                    Spacer()
                }
                .font(.title2.weight(.bold))
                .padding(.vertical, 16)
                .foregroundStyle(Color.cyan)
                
                // MARK: - Details
                Group {
                    Text("Details:")
                        .font(.title2.weight(.semibold))
                    Text(list.details)
                        .font(.headline.weight(.light))
                }
                .padding(.bottom, 16)
//            }
//            
            // MARK: - Items
            ForEach(items) { item in
                HStack(spacing: 0) {
                    Text(" ▢ - ")
                        .foregroundStyle(Color.blue)
                    Text(item.name)
                    Spacer()
                }
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            }
            .padding(.bottom, 18)
            
//            if page == 1 && list.items.count < 12 {
            VStack(alignment: .leading, spacing: 2) {
                Text("Reusable Lists - https://apps.apple.com/us/app/reusable-lists/id6478542301?l=en")
                Text("By Otavio Zabaleta - https://otaviokz.github.io/")
            }
            .font(.subheadline)
            
            Spacer()
//            }
        }
        .padding(.horizontal, 24)
        .frame(width: Constants.pdfWidth, height: Constants.pdfHeight)
    }
    
//    var listItems: [ToDoItem] {
//        var items: [ToDoItem] = []
//        
//        if page == 1 && list.items.count >= 14 {
//            return Array(items.prefix(14))
//        }
//        return items
//    }
}


struct Constants {
    static let dotsPerInch: CGFloat = 72.0
    static let pageWidth: CGFloat = 8.5
    static let pageHeight: CGFloat = 11.0
    static let pdfWidth: CGFloat = 8.5 * dotsPerInch
    static let pdfHeight: CGFloat = 11.0 * dotsPerInch
    static let pdfSize: CGSize = CGSize(width: pdfWidth, height: pdfHeight)
    static let maxItemsFirstPage: Int = 16
    static let maxItemsMiddlePagePage: Int = 20
    static let maxItemsLasttPage: Int = 18
    
}

//struct PDFBuilder {
//    static func itemLists(for list: ToDoList) -> [([ToDoItem], Int)] {
//        var result: [([ToDoItem], Int)] = []
//        var page = 1
//        if list.items.count <= Constants.maxItemsFirstPage {
//            result = [(list.items.suffix(Constants.maxItemsFirstPage), page)]
//        } else {
//            result = [(list.items.suffix(Constants.maxItemsFirstPage), page)]
//            page += 1
//            
//            while result.count > 18 {
//                result.append(contentsOf: (list.items.suffix(18)
//            }
//        }
//        
//        return result
//    }
//}

//struct PDFViewBuilder {
//    static func createViews(for list: ToDoList) -> [PDFView] {
//        var views: [PDFView] = []
//        var remainingItems: [ToDoItem] = []
//        if list.items.count <= 14 {
//            views.append(PDFView(list: list, items: list.items, page: 1))
//        } else {
//            var page = 2
//            var remaining = list.items.distance(from: 14, to: list.items.count - 1)
//            var nextIndex = 14
//            while remaining < 18 {
//                remainingItems = list.items.suffix(18)
//                page += 1
//                views.append(PDFView(list: list, items: remainingItems, page: page))
//                
//            }
//        }
//        
//        
//        
//        if list.items.count > 31 {
//            views.append(PDFView(list: list, page: 2))
//        }
//        
//        return views
//    }
//}
