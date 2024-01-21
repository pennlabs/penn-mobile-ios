//
//  BuildingMapWebviewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/11/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import WebKit

class BuildingMapWebviewController: UIViewController, WKUIDelegate, WKNavigationDelegate, IndicatorEnabled {

    private var webView: WKWebView!

    private let searchTerm: String
    private let urlStr = "https://mobile.apps.upenn.edu/mobile/jsp/fast.do?fastStart=campusMapPage"

    private var isInitialLoad = true

    init(searchTerm: String) {
        self.searchTerm = searchTerm
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)

        _ = webView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: -300, widthConstant: 0, heightConstant: 0)

        let myURL = URL(string: urlStr)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)

        self.title = "Building Map"
        self.navigationController?.navigationItem.backBarButtonItem?.title = "Back"
        self.showActivity()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideActivity()
        if self.isInitialLoad {
            navigateWebview()
            self.isInitialLoad = false
        }
    }

    func navigateWebview() {
        webView.evaluateJavaScript("document.getElementById('searchText').value = \"\(searchTerm)\"") { (result, _) in
            if result != nil {
                self.webView.evaluateJavaScript("populateMapFromSearch();", completionHandler: nil)
                self.webView.evaluateJavaScript("document.getElementById('backButton').remove(); var a = document.getElementById('header').querySelector('.Action'); a.remove(); a = document.getElementById('header').querySelector('.Action'); a.style.marginLeft = '10px'", completionHandler: nil)
                self.webView.evaluateJavaScript("openDetailsPanel = (function(url) { return; });", completionHandler: nil)

                #if os(visionOS)
                let width: CGFloat = 100
                #else
                let width = UIScreen.main.bounds.width
                #endif
                self.webView.evaluateJavaScript("document.getElementById('map_canvas').style.maxWidth = '\(width)px';", completionHandler: nil)
                self.webView.evaluateJavaScript("document.querySelector('.gm-style').getElementsByTagName('img')[0].style.width = '\(width)px';", completionHandler: nil)
                return
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: self.navigateWebview)
            }
        }
    }

    @objc fileprivate func cancel(_ sender: Any) {
        _ = self.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
