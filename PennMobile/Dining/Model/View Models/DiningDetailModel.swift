//
//  DiningDetailModel.swift
//  PennMobile
//
//  Created by Josh Doman on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class DiningDetailModel {
    static private let server = "https://university-of-pennsylvania.cafebonappetit.com/cafe"
        
    static private let serverDictionary: [DiningVenueName: String] = {
        var dict = [DiningVenueName: String]()
        dict[.commons] = "1920-commons"
        dict[.mcclelland] = "mcclelland"
        dict[.falk] = "falk-dining-commons"
        dict[.english] = "kings-court-english-house"
        dict[.gourmetGrocer] = "1920-gourmet-grocer"
        dict[.joes] = "joes-cafe"
        dict[.marks] = "marks-cafe"
        dict[.houston] = "houston-market"
        dict[.starbucks] = "1920-starbucks"
        dict[.nch] = "new-college-house"
        dict[.hill] = "hill-house"
        dict[.mbaCafe] = "pret-a-manger-upper"
        dict[.pret] = "pret-a-manger-lower"
        return dict
    }()
    
    static var lastUpdated = Date()
    
    static var webviewDictionary = [DiningVenueName: UIWebView]()
    
    static func getUrl(for venue: DiningVenueName) -> String? {
        if let endPoint = serverDictionary[venue] {
            return "\(server)/\(endPoint)"
        }
        return nil
    }
    
    static func getWebview(for venue: DiningVenueName) -> UIWebView? {
        if !lastUpdated.isToday {
            webviewDictionary = [DiningVenueName: UIWebView]()
            lastUpdated = Date()
            return nil
        }
        return DiningDetailModel.webviewDictionary[venue]
    }
    
    static func set(webview: UIWebView, for venue: DiningVenueName) {
        DiningDetailModel.webviewDictionary[venue] = webview
    }
}

// MARK: - Webview Preloading
extension DiningDetailModel {
    static func preloadWebview(for venue: DiningVenueName) {
        /*if getWebview(for: venue) != nil { return }
        
        DiningAPI.instance.fetchDetailPageHTML(for: venue) { (html) in
            if let html = html {
                DispatchQueue.main.async {
                    let webview = UIWebView(frame: .zero)
                    webview.loadHTMLString(html, baseURL: nil)
                    DiningDetailModel.set(webview: webview, for: venue)
                }
            }
        }*/
    }
}
