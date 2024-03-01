//
//  HTMLView.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 01/03/2024.
//

import SwiftUI
import UIKit
import WebKit

struct HTMLView: UIViewRepresentable {
    
    let fileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "html") else { return }
        guard let htmlString = try? String(contentsOf: url, encoding: .utf8) else { return }
        
        webView.loadHTMLString(htmlString, baseURL: url)
    }
}

