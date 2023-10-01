//
//  FeatureAnnouncement.swift
//  PennMobile
//
//  Created by Josh Doman on 3/1/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON
import PennSharedCode

class FeatureAnnouncement {
    let source: String
    let title: String
    let description: String?
    let timestamp: String?
    let imageUrl: String
    let feature: Feature

    init(source: String, title: String, description: String?, timestamp: String?, imageUrl: String, feature: Feature) {
        self.source = source
        self.title = title
        self.description = description
        self.timestamp = timestamp
        self.imageUrl = imageUrl
        self.feature = feature
    }
}

// MARK: - JSON Parsing
extension FeatureAnnouncement {
    convenience init(json: JSON) throws {
        guard let source = json["source"].string,
            let title = json["title"].string,
            let imageUrl = json["image_url"].string,
            let featureStr = json["feature"].string else {
                throw NetworkingError.jsonError
        }

        guard let feature = Feature(rawValue: featureStr) else {
            throw NetworkingError.jsonError
        }

        let description = json["description"].string
        let timestamp = json["timestamp"].string
        self.init(source: source, title: title, description: description, timestamp: timestamp, imageUrl: imageUrl, feature: feature)
    }
}
