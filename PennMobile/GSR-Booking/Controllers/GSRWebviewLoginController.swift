//
//  GSRWebviewLogin.swift
//  PennMobile
//
//  Created by Josh Doman on 1/20/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit
import WebKit

protocol GSRWebviewLoginDelegate {
    func updateSessionID(_ sessionID: String)
}

class GSRWebviewLoginController: UIViewController, WKUIDelegate, WKNavigationDelegate{
    
    var webView: WKWebView!
    var delegate: GSRWebviewLoginDelegate!
    
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
        
        let myURL = URL(string: "https://apps.wharton.upenn.edu/gsr/")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        navigationItem.title = "PennKey Login"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        
        if url.absoluteString == "https://apps.wharton.upenn.edu/gsr/" {
            let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
            cookieStore.getAllCookies { (cookies) in
                for cookie in cookies {
                    if cookie.name == "sessionid" {
                        self.delegate.updateSessionID(cookie.value)
                        decisionHandler(.cancel)
                        self.dismiss(animated: true, completion: nil)
                        return
                    }
                }
                decisionHandler(.allow)
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
