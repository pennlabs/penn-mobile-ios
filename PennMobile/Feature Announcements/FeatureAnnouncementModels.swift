//
//  FeatureAnnouncementModels.swift
//  PennMobile
//
//  Created by Grace Li on 2/15/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

extension String {
    
    func isVersionGreaterThanOrEqual(to other: String) -> Bool {
        let lhs = self.split(separator: ".").compactMap { Int($0) }
        let rhs = other.split(separator: ".").compactMap { Int($0) }
        let maxCount = max(lhs.count, rhs.count)
        for i in 0..<maxCount {
            let l = i < lhs.count ? lhs[i] : 0
            let r = i < rhs.count ? rhs[i] : 0
            if l != r { return l > r }
        }
        return true
    }
}

struct ChangeLog: Codable {
    let cutoff: String
    let features: [NewFeature]
}

struct NewFeature: Codable, Equatable, Identifiable {
    var id: String
    let title: String
    let blurb: String
    let feature: FeatureIdentifier?
    let imageUrl: String?
    let version: String

    enum CodingKeys: String, CodingKey {
        case id, title, blurb, feature, imageUrl, version
    }
    init(id: String, title: String, blurb: String, feature: FeatureIdentifier?, imageUrl: String, version: String) {
        self.id = id
        self.title = title
        self.blurb = blurb
        self.feature = feature
        self.imageUrl = imageUrl
        self.version = version
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        blurb = try c.decode(String.self, forKey: .blurb)
        if let featureString = try? c.decode(String.self, forKey: .feature) {
            feature = FeatureIdentifier(rawValue: featureString)
        } else {
            feature = nil
        }
        imageUrl = try c.decodeIfPresent(String.self, forKey: .imageUrl)
        version = try c.decode(String.self, forKey: .version)
    }
    
    func encode(to encoder: Encoder) throws {
       var c = encoder.container(keyedBy: CodingKeys.self)
       try c.encode(id, forKey: .id)
       try c.encode(title, forKey: .title)
       try c.encode(blurb, forKey: .blurb)
       try c.encode(feature?.rawValue, forKey: .feature)
       try c.encode(imageUrl, forKey: .imageUrl)
       try c.encode(version, forKey: .version)
    }
}

