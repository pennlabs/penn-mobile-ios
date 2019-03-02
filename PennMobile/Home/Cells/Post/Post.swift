//
//  Post.swift
//  PennMobile
//
//  Created by Josh Doman on 3/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class Post {
    let source: String
    let title: String
    let description: String?
    let timestamp: String
    let imageUrl: String
    let postUrl: String
    
    init(source: String, title: String, description: String?, timestamp: String, imageUrl: String, postUrl: String) {
        self.source = source
        self.title = title
        self.description = description
        self.timestamp = timestamp
        self.imageUrl = imageUrl
        self.postUrl = postUrl
    }
}

// MARK: - JSON Parsing
extension Post {
    convenience init(json: JSON) throws {
        guard let source = json["source"].string,
            let title = json["title"].string,
            let timestamp = json["timestamp"].string,
            let imageUrl = json["image_url"].string,
            let postUrl = json["post_url"].string else {
                throw NetworkingError.jsonError
        }
        
        let description = json["description"].string
        self.init(source: source, title: title, description: description, timestamp: timestamp, imageUrl: imageUrl, postUrl: postUrl)
    }
}
