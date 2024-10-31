//
//  PDFCreator.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 30/10/2024.
//

import Foundation
import SwiftUI
import PDFKit

class PDFCreator {
    
    // This can be any object that stores your page information
    let page: PDFInfo
    
    private let metaData = [
        kCGPDFContextAuthor: "Otavio Zabaleta",
        kCGPDFContextSubject: "This is a demo on how to create a PDF from a SwiftUI View"
    ]
    
    private var rect: CGRect {
        CGRect(origin: .zero, size: Constants.pdfSize)
    }
    
    init(page: PDFInfo) {
        self.page = page
    }
    
    @MainActor
    func createPDFData(displayScale: CGFloat) -> URL {
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = metaData as [String: Any]
        let renderer = UIGraphicsPDFRenderer(bounds: rect, format: format)
        
        let tempFolder = FileManager.default.temporaryDirectory
        let fileName = "My Custom PDF Title.pdf"
        let tempURL = tempFolder.appendingPathComponent(fileName)
        
        try? renderer.writePDF(to: tempURL) { context in
//            for info in multiplePages {
                context.beginPage()
            let imageRenderer = ImageRenderer(content: PDFView(list: page.list/*, items: page.list.items, page: 1)*/))
                imageRenderer.scale = displayScale
                imageRenderer.uiImage?.draw(at: CGPoint.zero)
//            }
        }
        
        return tempURL
    }
}

//extension PDFCreator {
//    func createPageViews(list: [ToDoItem]) -> [PageView] {
//        
//    }
//}
