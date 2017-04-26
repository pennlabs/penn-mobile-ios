//
//  GenericWebview.swift
//  PennMobile
//
//  Created by Josh Doman on 4/15/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class GenericWebview: UIWebView, IndicatorEnabled {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
        showActivity()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GenericWebview: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hideActivity()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        hideActivity()
    }
}
