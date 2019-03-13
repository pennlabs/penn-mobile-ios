//
//  GSRWebviewLogin.swift
//  PennMobile
//
//  Created by Josh Doman on 1/20/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit
import WebKit

class GSRWebviewLoginController: PennLoginController {
    
    var webView: WKWebView!
    var completion: (() -> Void)?
    
    override var urlStr: String {
        return "https://apps.wharton.upenn.edu/gsr/"
    }
    
    override func handleSuccessfulNavigation(_ webView: WKWebView, decidePolicy navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { (cookies) in
            DispatchQueue.main.async {
                for cookie in cookies {
                    if cookie.name == "sessionid" {
                        UserDefaults.standard.set(sessionID: cookie.value)
                        decisionHandler(.cancel)
                        self.dismiss(animated: true, completion: nil)
                        self.completion?()
                        return
                    }
                }
                decisionHandler(.allow)
            }
        }
    }
}
