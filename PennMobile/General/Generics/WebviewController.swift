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
    static var htmlDictionary = [String: String]()
    
    var webview: GenericWebview!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeMenuButton()
        self.isPanEnabled = false
    }
    
    func load(for urlString: String) {
        webview = GenericWebview(frame: .zero)
        view.addSubview(webview)
        webview.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        if let html = WebviewController.getHTML(for: urlString) {
            webview.loadHTMLString(html, baseURL: nil)
        } else {
            guard let url = URL(string: urlString) else { return }
            if let html = try? String(contentsOf: url, encoding: .ascii) {
                DispatchQueue.main.async {
                    self.webview.loadHTMLString(html, baseURL: nil)
                    WebviewController.setHTML(html, for: urlString)
                }
            }
        }
    }
}

// MARK: - Caching
extension WebviewController {
    static func getHTML(for url: String) -> String? {
        if !lastUpdated.isToday {
            htmlDictionary = [String: String]()
            lastUpdated = Date()
            return nil
        }
        return htmlDictionary[url]
    }
    
    static func setHTML(_ html: String, for url: String) {
        htmlDictionary[url] = html
    }
}

// MARK: - Webview Preloading
extension WebviewController {
    static func preloadWebview(for urlString: String) {
        if getHTML(for: urlString) != nil { return }
        DispatchQueue.global(qos: .background).async {
            guard let url = URL(string: urlString) else { return }
            if let html = try? String(contentsOf: url, encoding: .ascii) {
                WebviewController.setHTML(html, for: urlString)
            }
        }
    }
}
