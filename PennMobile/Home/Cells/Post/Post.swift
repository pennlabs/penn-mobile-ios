//
//  Post.swift
//  PennMobile
//
//  Created by Josh Doman on 3/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class Post {
    let source: String?
    let title: String?
    let subtitle: String?
    let timeLabel: String?
    let imageUrl: String
    let postUrl: String?
    let id: Int
    let isTest: Bool
    
    init(source: String?, title: String?, subtitle: String?, timeLabel: String?, imageUrl: String, postUrl: String?, id: Int, isTest: Bool) {
        self.source = source
        self.title = title
        self.subtitle = subtitle
        self.timeLabel = timeLabel
        self.imageUrl = imageUrl
        self.postUrl = postUrl
        self.id = id
        self.isTest = isTest
    }
}

// MARK: - JSON Parsing
extension Post {
    convenience init(json: JSON) throws {
        guard let imageUrl = json["image_url"].string, let id = json["post_id"].int, let isTest = json["test"].bool else {
            // All posts must have at least an image, an id, and a test flag
            throw NetworkingError.jsonError
        }
        
        let source = json["source"].string
        let title = json["title"].string
        let subtitle = json["subtitle"].string
        let postUrl = json["post_url"].string
        let timeLabel = json["time_label"].string
        
        if (source == nil && timeLabel != nil) || (title == nil && subtitle == nil && source != nil) || (title == nil && subtitle != nil) {
            // Rules:
            //  (1) A time label cannot exist without a source label
            //  (2) An image cannot be accompanied with only a source label
            //  (3) A subtitle cannot exist without a title
            throw NetworkingError.jsonError
        }
        
        self.init(source: source, title: title, subtitle: subtitle, timeLabel: timeLabel, imageUrl: imageUrl, postUrl: postUrl, id: id, isTest: isTest)
    }
}
