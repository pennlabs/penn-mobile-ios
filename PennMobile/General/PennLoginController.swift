//
//  PennLoginController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/13/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import WebKit

class PennLoginController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    final private let loginURL = "https://weblogin.pennkey.upenn.edu/login"
    open var urlStr: String {
        return "https://weblogin.pennkey.upenn.edu/login"
    }
    
    open var pennkey: String?
    private var password: String?
    final private let testPennKey = "joshdo"
    
    final private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let wkDataStore = WKWebsiteDataStore.nonPersistent()
        let sharedCookies: Array<HTTPCookie> = HTTPCookieStorage.shared.cookies ?? []
        let dispatchGroup = DispatchGroup()
        
        if sharedCookies.count > 0 {
            for cookie in sharedCookies {
                dispatchGroup.enter()
                wkDataStore.httpCookieStore.setCookie(cookie) {
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: DispatchQueue.main) {
                self.configureAndLoad(wkDataStore: wkDataStore)
            }
        } else {
            self.configureAndLoad(wkDataStore: wkDataStore)
        }
        
        navigationItem.title = "PennKey Login"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        
        pennkey = UserDefaults.standard.getPennKey()
        password = UserDefaults.standard.getPassword()
    }
    
    func configureAndLoad(wkDataStore: WKWebsiteDataStore) {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = wkDataStore
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view = webView

        let myURL = URL(string: self.urlStr)
        let myRequest = URLRequest(url: myURL!)
        self.webView.load(myRequest)
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
        
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { (cookies) in
            cookies.forEach({ (cookie) in
                HTTPCookieStorage.shared.setCookie(cookie)
            })
            
            let hasReferer = request.allHTTPHeaderFields?["Referer"] != nil
            if url.absoluteString == self.urlStr, hasReferer {
                // Webview has redirected to desired site.
                self.handleSuccessfulNavigation(webView, decisionHandler: decisionHandler)
            } else {
                if url.absoluteString == self.loginURL {
                    webView.evaluateJavaScript("document.getElementById('pennkey').value;") { (result, error) in
                        if let pennkey = result as? String {
                            webView.evaluateJavaScript("document.getElementById('password').value;") { (result, error) in
                                if let password = result as? String {
                                    self.pennkey = pennkey
                                    self.password = password
                                }
                                decisionHandler(.allow)
                            }
                        } else {
                            decisionHandler(.allow)
                        }
                    }
                } else {
                    decisionHandler(.allow)
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let response = navigationResponse.response as? HTTPURLResponse, let url = response.url else {
            decisionHandler(.allow)
            return
        }
        
        if url.absoluteString == urlStr, response.statusCode == 200 {
            self.handleSuccessfulNavigation(webView) { (policy) in
                decisionHandler(policy == WKNavigationActionPolicy.allow ? WKNavigationResponsePolicy.allow : WKNavigationResponsePolicy.cancel)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }
        
        if url.absoluteString == loginURL {
            guard let pennkey = pennkey, let password = password else { return }
            UserDefaults.standard.set(pennkey: pennkey)
            UserDefaults.standard.set(password: password)
            if !UserDBManager.shared.testRun && pennkey == self.testPennKey {
                self.dismiss(animated: true, completion: nil)
            }
            return
        } else if url.absoluteString.contains(loginURL) {
            self.autofillCredentials()
        }
    }
    
    func autofillCredentials() {
        guard let pennkey = pennkey, let password = password else { return }
        webView.evaluateJavaScript("document.getElementById('pennkey').value = '\(pennkey)'") { (_,_) in
        }
        webView.evaluateJavaScript("document.getElementById('password').value = '\(password)'") { (_,_) in
        }
    }
    
    @objc fileprivate func cancel(_ sender: Any) {
        _ = self.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Decide Policy Upon Completed Navigation
    // Note: This should be overridden when extending this class
    func handleSuccessfulNavigation(
        _ webView: WKWebView,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.dismiss(animated: true, completion: nil)
        decisionHandler(.cancel)
    }
}

