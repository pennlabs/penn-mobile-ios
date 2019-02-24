//
//  LoginWebviewController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import WebKit

class LoginWebviewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView!
    var completion: (() -> Void)?
    
    private let urlStr = "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do?fastStart=mobile"
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: urlStr)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        navigationItem.title = "PennKey Login"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        guard let url = request.url else {
            decisionHandler(.allow)
            return
        }
        
        let hasReferer = request.allHTTPHeaderFields?["Referer"] != nil
        if url.absoluteString == urlStr, hasReferer {
            let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
            cookieStore.getAllCookies { (cookies) in
                CourseNetworkManager.instance.getCourses(request: request, cookies: cookies, callback: { courses in
                    DispatchQueue.main.async {
                        courses?.forEach { print($0.description) }
                        self.dismiss(animated: true, completion: nil)
                        decisionHandler(.cancel)
                    }
                })
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    @objc fileprivate func cancel(_ sender: Any) {
        _ = self.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}
