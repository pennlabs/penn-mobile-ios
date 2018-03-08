//
//  WebviewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/7/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class WebviewController: GenericViewController {
    static var lastUpdated = Date()
    static var webviewDictionary = [String: UIWebView]()
    
    var webview: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeMenuButton()
        self.isPanEnabled = false
    }
    
    func load(for urlString: String) {
        webview = WebviewController.getWebview(for: urlString)
        if webview == nil {
            webview = GenericWebview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
            guard let url = URL(string: urlString) else { return }
            webview.loadRequest(URLRequest(url: url))
            WebviewController.set(webview: webview, for: urlString)
        }
        
        view.addSubview(webview)
        webview.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
}

// MARK: - Caching
extension WebviewController {
    static func getWebview(for url: String) -> UIWebView? {
        if !lastUpdated.isToday {
            webviewDictionary = [String: UIWebView]()
            lastUpdated = Date()
            return nil
        }
        return WebviewController.webviewDictionary[url]
    }
    
    static func set(webview: UIWebView, for url: String) {
        WebviewController.webviewDictionary[url] = webview
    }
}

// MARK: - Webview Preloading
extension WebviewController {
    static func preloadWebview(for urlString: String) {
        if getWebview(for: urlString) != nil { return }
        DispatchQueue.global(qos: .background).async {
            guard let url = URL(string: urlString) else { return }
            if let html = try? String(contentsOf: url, encoding: .ascii) {
                DispatchQueue.main.async {
                    let webview = UIWebView(frame: .zero)
                    webview.loadHTMLString(html, baseURL: nil)
                    WebviewController.set(webview: webview, for: urlString)
                }
            }
        }
    }
}
