//
//  NewsArticle.swift
//  PennMobile
//
//  Created by Josh Doman on 2/7/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

class NewsArticle {
    let source: String
    let title: String
    let subtitle: String
    let timestamp: String
    let imageUrl: String
    let articleUrl: String
    
    init(source: String, title: String, subtitle: String, timestamp: String, imageUrl: String, articleUrl: String) {
        self.source = source
        self.title = title
        self.subtitle = subtitle
        self.timestamp = timestamp
        self.imageUrl = imageUrl
        self.articleUrl = articleUrl
    }
}

// MARK: - JSON Parsing
extension NewsArticle {
    convenience init(json: JSON) throws {
        guard let source = json["source"].string,
            let title = json["title"].string,
            let subtitle = json["subtitle"].string,
            let timestamp = json["timestamp"].string,
            let imageUrl = json["image_url"].string,
            let articleUrl = json["article_url"].string else {
                throw NetworkingError.jsonError
        }
        
        self.init(source: source, title: title, subtitle: subtitle, timestamp: timestamp, imageUrl: imageUrl, articleUrl: articleUrl)
    }
}
