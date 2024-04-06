//
//  PennLoginController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/13/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//
import Foundation
import WebKit
import PennMobileShared

class PennLoginController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    final private let loginURL = "https://weblogin.pennkey.upenn.edu/login"
    final private let loginScreen = "https://weblogin.pennkey.upenn.edu/idp/profile/SAML2/Redirect/SSO?execution=e1"
    open var urlStr: String {
        return "https://weblogin.pennkey.upenn.edu/services/"
    }

    open var pennkey: String?
    private var password: String?

    final private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!

    var shouldAutoNavigate: Bool = true
    var shouldLoadCookies: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .uiBackground

        WKWebsiteDataStore.createDataStoreWithSavedCookies { (dataStore) in
            self.configureAndLoad(wkDataStore: dataStore)
        }

        navigationItem.title = "PennKey Login"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))

        self.pennkey = KeychainAccessible.instance.getPennKey()
        self.password = KeychainAccessible.instance.getPassword()
    }

    func configureAndLoad(wkDataStore: WKWebsiteDataStore) {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = shouldLoadCookies ? wkDataStore : .nonPersistent()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        self.view = webView

        let myURL = URL(string: self.urlStr)
        let myRequest = URLRequest(url: myURL!)
        self.webView.load(myRequest)
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        self.view.addSubview(activityIndicator)
        self.view.bringSubviewToFront(activityIndicator)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicator.center = view.center
        view.bringSubviewToFront(activityIndicator)
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
        
        if navigationAction.navigationType == .formSubmitted,
           webView.url?.absoluteString.contains(loginScreen) == true {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            view.isUserInteractionEnabled = false
        }

        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { (cookies) in
            cookies.forEach({ (cookie) in
                HTTPCookieStorage.shared.setCookie(cookie)
            })

            let hasReferer = request.allHTTPHeaderFields?["Referer"] != nil
            if self.isSuccessfulRedirect(url: url.absoluteString, hasReferer: hasReferer) {
                // Webview has redirected to desired site.
                self.handleSuccessfulNavigation(webView, decisionHandler: decisionHandler)
            } else {
                webView.evaluateJavaScript("document.querySelector('input[name=j_username]').value;") { (result, _) in
                    if let pennkey = result as? String {
                        webView.evaluateJavaScript("document.querySelector('input[name=j_password]').value;") { (result, _) in
                            if let password = result as? String {
                                if !pennkey.isEmpty && !password.isEmpty {
                                    self.pennkey = pennkey
                                    self.password = password
                                    if pennkey == "root" && password == "root" {
                                        self.handleDefaultLogin(decisionHandler: decisionHandler)
                                        return
                                    }
                                }
                            }
                            decisionHandler(.allow)
                        }
                    } else {
                        decisionHandler(.allow)
                    }
                }
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let response = navigationResponse.response as? HTTPURLResponse, let url = response.url else {
            decisionHandler(.allow)
            return
        }
        
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        view.isUserInteractionEnabled = true

        if self.isSuccessfulRedirect(url: url.absoluteString, hasReferer: true), response.statusCode == 200 {
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

        if url.absoluteString.contains("prompt") {
            guard let pennkey = pennkey, let password = password else { return }
            if password != KeychainAccessible.instance.getPassword() {
                UserDBManager.shared.updateAnonymizationKeys()
            }
            KeychainAccessible.instance.savePennKey(pennkey)
            KeychainAccessible.instance.savePassword(password)
        } else {
            self.autofillCredentials()
            self.trustDevice()
        }
    }

    func autofillCredentials() {
        guard let pennkey = pennkey else { return }
        webView.evaluateJavaScript("document.getElementById('username').value = '\(pennkey)'") { (_, _) in
        }
        guard let password = password else { return }
        webView.evaluateJavaScript("document.getElementById('password').value = '\(password)'") { (_, _) in
        }
    }

    func trustDevice() {
        webView.evaluateJavaScript("document.getElementById('trustUA').value = 'true'") { (_, _) in
            self.webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (_, _) in
            }
        }
    }

    var handleCancel: (() -> Void)?

    @objc fileprivate func cancel(_ sender: Any) {
        _ = self.resignFirstResponder()
        dismiss(animated: true, completion: self.handleCancel)
    }

    // MARK: - Decide Policy Upon Completed Navigation
    // Note: This should be overridden when extending this class
    func handleSuccessfulNavigation(
        _ webView: WKWebView,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { (cookies) in
            DispatchQueue.main.async {
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
                UserDefaults.standard.storeCookies()
                decisionHandler(.cancel)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    // Note: This should be overridden when extending this class
    func handleDefaultLogin(decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Verify Successful Redirect
    func isSuccessfulRedirect(url: String, hasReferer: Bool) -> Bool {
        return url == self.urlStr && hasReferer
    }
}

extension WKWebsiteDataStore {
    static func createDataStoreWithSavedCookies(_ callback: @escaping (WKWebsiteDataStore) -> Void) {
        let wkDataStore = WKWebsiteDataStore.nonPersistent()
        let sharedCookies: [HTTPCookie] = HTTPCookieStorage.shared.cookies ?? []
        let dispatchGroup = DispatchGroup()

        if sharedCookies.count > 0 {
            for cookie in sharedCookies {
                dispatchGroup.enter()
                wkDataStore.httpCookieStore.setCookie(cookie) {
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: DispatchQueue.main) {
                callback(wkDataStore)
            }
        } else {
            callback(wkDataStore)
        }
    }
}
