//
//  DiningDetailViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/31/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class DiningDetailViewController: GenericViewController {
    
    let server = "http://university-of-pennsylvania.cafebonappetit.com/cafe"
    
    let serverDictionary: [String: String] = {
        var dict = [String: String]()
        dict["1920 Commons"] = "1920-commons"
        dict["McClelland Express"] = "mcclelland"
        dict["Beefsteak"] = "beefsteak"
        dict["Falk Kosher Dining"] = "falk-dining-commons"
        dict["English House"] = "kings-court-english-house"
        dict["Gourmet Grocer"] = "1920-gourmet-grocer"
        dict["Joe's Café"] = "joes-cafe"
        dict["Mark's Café"] = "marks-cafe"
        dict["Tortas Frontera"] = "tortas-frontera-at-the-arch"
        dict["Houston Market"] = "houston-market"
        dict["Starbucks"] = "1920-starbucks"
        dict["New College House"] = "new-college-house"
        dict["Hill House"] = "hill-house"
        return dict
    }()

    var venue: DiningVenue!
    
    var webview: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeMenuButton()
        
        webview = GenericWebview(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        view.addSubview(webview)
        
        if let endPoint = serverDictionary[venue.name] {
            let urlString = "\(server)/\(endPoint)"
            
            if let url = URL(string: urlString) {
                webview.loadRequest(URLRequest(url: url))
            }
        }
        
        self.screenName = venue.name
        self.title = venue.name
        self.isPanEnabled = false
        self.trackScreen = true
    }
}
