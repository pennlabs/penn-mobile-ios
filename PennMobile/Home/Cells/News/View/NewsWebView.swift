//
//  NewsWebView.swift
//  PennMobile
//
//  Created by Jacky on 2/9/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

// MARK: - used in external news view, part of effort to replace NewsViewController (3 segmented news view)

import SwiftUI
import WebKit

struct NewsWebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}
