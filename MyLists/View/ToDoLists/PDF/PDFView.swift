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
//    let items: [ToDoItem]
//    let page: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header
//            if page == 1 {
                HStack {
                    Spacer()
                    Image.todolist
                    Text(" - \(list.name)")
                        .font(.title.weight(.bold))
                    Spacer()
                }
                .padding(.bottom, 4)
                .foregroundStyle(Color.cyan)
                
                // MARK: - Details
                Group {
                    Text("Details:")
                        .font(.title3.weight(.semibold))
                    //                    .padding(.bottom, 2)
                    Text(list.details)
                        .font(.headline.weight(.light))
                }
                .foregroundStyle(Color.gray)
                .padding(.bottom, 12)
//            }
//            
            // MARK: - Items
            ForEach(list.items) { item in
                HStack {
                    Text(" ▢ - ")
                        .foregroundStyle(Color.cyan)
                    Text(item.name)
                    Spacer()
                }
                .font(.headline.weight(.light))
                .multilineTextAlignment(.leading)
            }
            .padding(.bottom, 12)
            
//            if page == 1 && list.items.count < 12 {
            VStack(alignment: .leading, spacing: 0) {
                    Text("Reusable Lists - https://apps.apple.com/us/app/reusable-lists/id6478542301?l=en")
                        .font(.subheadline)
                    
                    Text("By Otavio Zabaleta - https://otaviokz.github.io/")
                        .font(.subheadline)
                }
//            }
        }
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
    static let maxItemsFirstPage: Int = 14
    static let maxItemsMiddlePagePage: Int = 18
    static let maxItemsLasttPage: Int = 16
    
}

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
