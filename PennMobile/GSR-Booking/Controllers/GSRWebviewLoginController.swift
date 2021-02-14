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
    
    var completion: (() -> Void)?
    var shouldAnimate = true
    
    override var urlStr: String {
        return "https://apps.wharton.upenn.edu/gsr/"
    }
    
    override func handleSuccessfulNavigation(_ webView: WKWebView, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { (cookies) in
            DispatchQueue.main.async {
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
                decisionHandler(.cancel)
                self.dismiss(animated: self.shouldAnimate, completion: nil)
                self.completion?()
                UserDefaults.standard.storeCookies()
                
                if GSRUser.getSessionCookie() != nil {
                    UserDefaults.standard.set(isInWharton: true)
                }
            }
        }
    }
}
