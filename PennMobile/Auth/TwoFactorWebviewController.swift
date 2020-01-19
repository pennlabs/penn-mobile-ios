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
        var completed = false
        decisionHandler(.cancel)
        TOTPFetcher.instance.fetchAndSaveTOTPSecret { (secret) in
            DispatchQueue.main.async {
                if !completed {
                    self.hideActivity()
                    self.dismiss(animated: true, completion: nil)
                    completed = true
                }
                self.completion?(secret != nil)
            }
        }
        //Hide the screen after 5 seconds, but continue fetching the code in the background
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if !completed {
                self.hideActivity()
                self.dismiss(animated: true, completion: nil)
                completed = true
            }
        }
        UserDefaults.standard.storeCookies()
    }
}
