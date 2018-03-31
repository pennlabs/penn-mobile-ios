//
//  DiningDetailViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/31/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class DiningDetailViewController: GenericViewController {
    
    var venue: DiningVenue!
    var webview: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeMenuButton()
        
        webview = DiningDetailModel.getWebview(for: venue.name)
        if webview == nil {
            webview = GenericWebview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
            guard let urlString = DiningDetailModel.getUrl(for: venue.name),
                let url = URL(string: urlString) else {
                return
            }
            webview.loadRequest(URLRequest(url: url))
            DiningDetailModel.set(webview: webview, for: venue.name)
        }
        
        view.addSubview(webview)
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        self.screenName = venue.name.rawValue
        self.title = venue.name.rawValue
        self.isPanEnabled = false
        self.trackScreen = true
    }
}
