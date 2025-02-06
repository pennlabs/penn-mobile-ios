//
//  DiningLoginViewController.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 1/28/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation
import WebKit
import PennMobileShared

class DiningLoginController: UIViewController, WKUIDelegate, WKNavigationDelegate, SHA256Hashable {
    static let activityIndicatorAnimationDuration: TimeInterval = 0.1

    final private var webView: WKWebView!
    private var activityIndicatorBackground: UIVisualEffectView!
    private var activityIndicator: UIActivityIndicatorView!

    var clientId = "5c09c08b240a56d22f06b46789d0528a"

    var urlStr: String {
        return
            "https://prod.campusexpress.upenn.edu/api/v1/oauth/authorize"
    }
    final private let loginScreen = "https://weblogin.pennkey.upenn.edu/idp/profile/SAML2/Redirect/SSO?execution=e1"

    var delegate: DiningLoginControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        navigationItem.title = "Campus Express Authorization"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))

        webView = WKWebView(frame: .zero)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view = webView

        var url = URL(string: urlStr)!
        url.appendQueryItem(name: "response_type", value: "code")
        url.appendQueryItem(name: "client_id", value: clientId)
        url.appendQueryItem(name: "state", value: stateString)
        url.appendQueryItem(name: "scope", value: "read")
        url.appendQueryItem(name: "code_challenge", value: codeChallenge)
        url.appendQueryItem(name: "code_challenge_method", value: "S256")
        url.appendQueryItem(name: "redirect_uri", value: "https://pennlabs.org/pennmobile/ios/campus_express_callback/")

        webView.load(URLRequest(url: url))
        
        activityIndicatorBackground = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
        activityIndicatorBackground.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicatorBackground.layer.cornerRadius = 16
        activityIndicatorBackground.clipsToBounds = true
        activityIndicatorBackground.layer.opacity = 0
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = CGPoint(x: activityIndicatorBackground.bounds.midX, y: activityIndicatorBackground.bounds.midY)
        activityIndicatorBackground.contentView.addSubview(activityIndicator)
        
        self.view.addSubview(activityIndicatorBackground)
        self.view.bringSubviewToFront(activityIndicatorBackground)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let activityIndicatorBackground {
            activityIndicatorBackground.center = view.center
            view.bringSubviewToFront(activityIndicatorBackground)
        }
    }

    var handleCancel: (() -> Void)?

    @objc fileprivate func cancel(_ sender: Any) {
        dismiss(animated: true, completion: self.handleCancel)
    }

    private let codeVerifier = String.randomString(length: 64)

    private let state = String.randomString(length: 64)

    private var codeChallenge: String {
        var challenge = hash(string: codeVerifier, encoding: .base64)
        challenge.removeAll(where: { $0 == "=" })
        challenge = challenge.replacingOccurrences(of: "+", with: "-")
        challenge = challenge.replacingOccurrences(of: "/", with: "_")
        return challenge
    }

    private var stateString: String {
        var state = state
        state.removeAll(where: { $0 == "=" })
        state = state.replacingOccurrences(of: "+", with: "-")
        state = state.replacingOccurrences(of: "/", with: "_")
        return state
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        view.isUserInteractionEnabled = true
        UIView.animate(withDuration: Self.activityIndicatorAnimationDuration) {
            self.activityIndicatorBackground.layer.opacity = 0
        } completion: { _ in
            self.activityIndicator.stopAnimating()
        }
        
        if let url = navigationResponse.response.url, url.absoluteString.contains("https://pennlabs.org/pennmobile/ios/campus_express_callback/") {
            let queryParams = url.queryParameters

            guard queryParams["state"] == stateString else { return }

            if let code = queryParams["code"] {
                var url = URL(string: "https://prod.campusexpress.upenn.edu/api/v1/oauth/token")!
                url.appendQueryItem(name: "client_id", value: clientId)
                url.appendQueryItem(name: "code_verifier", value: codeVerifier)
                url.appendQueryItem(name: "grant_type", value: "authorization_code")
                url.appendQueryItem(name: "code", value: code)
                url.appendQueryItem(name: "redirect_uri", value: "https://pennlabs.org/pennmobile/ios/campus_express_callback/")

                let task = URLSession.shared.dataTask(with: url) { [self] (data, _, _) in
                    let decoder = JSONDecoder()

                    guard let data = data else { decisionHandler(.allow); return }

                    if let token = try? decoder.decode(DiningToken.self, from: data) {
                        KeychainAccessible.instance.saveDiningToken(token.value)
                        UserDefaults.standard.setDiningTokenExpiration(token.expirationDate)
                        delegate.dismissDiningLoginController()
                    }

                }

                task.resume()
            }
        } else if let url = navigationResponse.response.url,
        url.absoluteString.contains("https://prod.campusexpress.upenn.edu/help-support-alt.jsp") {
            delegate.dismissDiningLoginController()
        }

        decisionHandler(.allow)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .formSubmitted,
           webView.url?.absoluteString.contains(loginScreen) == true {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: Self.activityIndicatorAnimationDuration) {
                self.activityIndicatorBackground.layer.opacity = 1
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }

        if url.absoluteString.contains("https://weblogin.pennkey.upenn.edu/") {
            guard let pennkey = KeychainAccessible.instance.getPennKey(), let password = KeychainAccessible.instance.getPassword() else { return }
            webView.evaluateJavaScript("document.getElementById('username').value = '\(pennkey)'") { (_, _) in
                webView.evaluateJavaScript("document.getElementById('password').value = '\(password)'") { (_, _) in
                }
            }
        }
    }
}
