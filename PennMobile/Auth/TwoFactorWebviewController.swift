//
//  TwoFactorWebviewController.swift
//  PennMobile
//
//  Created by Henrique Lorente on 12/6/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//
import Foundation
import WebKit

class TwoFactorWebviewController: PennLoginController, IndicatorEnabled {
    
    override var shouldLoadCookies: Bool {
        return false
    }
    
    var completion : ((_ successful: Bool) -> Void)? = nil
    
    override var urlStr: String {
        return "https://twostep.apps.upenn.edu/twoFactor/twoFactorUi/app/UiMain.index"
    }
    
    override func handleSuccessfulNavigation(_ webView: WKWebView, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.showActivity()
        TOTPFetcher.instance.fetchAndSaveTOTPSecret { (secret) in
            DispatchQueue.main.async {
                decisionHandler(.cancel)
                self.hideActivity()
                self.dismiss(animated: true, completion: nil)
                self.completion?(secret != nil)
            }
        }
        UserDefaults.standard.storeCookies()
    }
    
}
