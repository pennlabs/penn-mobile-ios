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
    var loginCompletion: ((_ student: Student?) -> Void)!
    var coursesRetrieved: ((_ course: Set<Course>?) -> Void)!
    
    private let loginURL = "https://weblogin.pennkey.upenn.edu/login"
    private let urlStr = "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do"
    
    private var pennkey: String?
    private let testPennKey = "joshdo"
    
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
            // Webview has redirected to PennInTouch.
            let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
            cookieStore.getAllCookies { (cookies) in
                StudentNetworkManager.instance.getStudent(request: request, cookies: cookies, initialCallback: { student in
                    DispatchQueue.main.async {
                        if let student = student {
                            if self.pennkey == nil {
                                // PennKey not guaranteed to be fetched yet. If it's not, fetch it before continuing.
                                StudentNetworkManager.instance.getPennKey(cookies: cookies, callback: { pennkey in
                                    DispatchQueue.main.async {
                                        student.pennkey = pennkey
                                        student.setEmail()
                                        self.loginCompletion(student)
                                        self.dismiss(animated: true, completion: nil)
                                        decisionHandler(.cancel)
                                    }
                                })
                            } else {
                                student.setEmail()
                                self.loginCompletion(student)
                                self.dismiss(animated: true, completion: nil)
                                decisionHandler(.cancel)
                            }
                        } else {
                            self.loginCompletion(nil)
                            self.dismiss(animated: true, completion: nil)
                            decisionHandler(.cancel)
                        }
                    }
                }, allCoursesCallback: { courses in
                    self.coursesRetrieved(courses)
                })
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
            // Webview has redirected to 2FA login. Fetch the PennKey now in order to dismiss in case this is an AppStore tester.
            let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
            cookieStore.getAllCookies { (cookies) in
                StudentNetworkManager.instance.getPennKey(cookies: cookies, callback: { pennkey in
                    DispatchQueue.main.async {
                        self.pennkey = pennkey
                        if !UserDBManager.shared.testRun && pennkey == self.testPennKey {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                })
            }
            return
        }
    }
    
    @objc fileprivate func cancel(_ sender: Any) {
        _ = self.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}
