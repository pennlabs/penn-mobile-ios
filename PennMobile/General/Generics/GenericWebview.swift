//
//  GenericWebview.swift
//  PennMobile
//
//  Created by Josh Doman on 4/15/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class GenericWebview: UIWebView, IndicatorEnabled {
    
    internal var load: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadRequest(_ request: URLRequest) {
        super.loadRequest(request)
        load = true
        showActivity()
    }
}

extension GenericWebview: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if load {
            hideActivity()
            load = false
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if load {
            hideActivity()
            load = false
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        if navigationType == .linkClicked {
//            return false
//        }
        return true
    }
}
