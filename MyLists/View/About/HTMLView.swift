//
//  HTMLView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 01/03/2024.
//

import SwiftUI
import UIKit
import WebKit

struct HTMLView: UIViewRepresentable {
    
    let fileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let wkWebView = WKWebView()
        wkWebView.backgroundColor = .clear
        wkWebView.scrollView.showsVerticalScrollIndicator = false
        wkWebView.scrollView.showsHorizontalScrollIndicator = false
        wkWebView.layer.borderWidth = 0.5
        wkWebView.layer.borderColor = UIColor.lightGray.cgColor
        wkWebView.layer.cornerRadius = 8
        wkWebView.clipsToBounds = true
        return wkWebView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "html") else { return }
        guard let htmlString = try? String(contentsOf: url, encoding: .utf8) else { return }
        webView.loadHTMLString(htmlString, baseURL: url)
    }
}
