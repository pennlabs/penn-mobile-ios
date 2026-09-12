//
//  Sublet.swift
//  PennMobile
//
//  Created by Anthony Li on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

@dynamicMemberLookup
public struct Sublet: Identifiable, Codable, Hashable, Sendable {
    public let subletID: Int
    public var data: SubletData
    public var subletter: Int
    public var offers: [SubletOffer]?
    public var images: [SubletImage]
    
    public var lastUpdated: Date
    public var id: String {
        "\(subletID)-\(lastUpdated.timeIntervalSinceReferenceDate)"
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<SubletData, T>) -> T {
        data[keyPath: keyPath]
    }

    public init(subletID: Int, data: SubletData, subletter: Int, offers: [SubletOffer]? = nil, images: [SubletImage], lastUpdated: Date = Date()) {
        self.subletID = subletID
        self.data = data
        self.subletter = subletter
        self.offers = offers
        self.images = images
        self.lastUpdated = lastUpdated
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let subletID = try container.decode(Int.self, forKey: .subletID)
        let data = try SubletData(from: decoder)
        let subletter = try container.decode(Int.self, forKey: .subletter)
        let offers = try container.decodeIfPresent([SubletOffer].self, forKey: .offers)
        let images = try container.decode([SubletImage].self, forKey: .images)
        let lastUpdated = try container.decodeIfPresent(Date.self, forKey: .lastUpdated) ?? Date()

        self.init(subletID: subletID, data: data, subletter: subletter, offers: offers, images: images, lastUpdated: lastUpdated)
    }
    
    enum CodingKeys: String, CodingKey {
        case subletID = "id"
        case subletter
        case offers
        case images
        case lastUpdated
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(subletID, forKey: .subletID)
        try data.encode(to: encoder)
        try container.encode(subletter, forKey: .subletter)
        try container.encodeIfPresent(offers, forKey: .offers)
        try container.encode(images, forKey: .images)
        try container.encode(lastUpdated, forKey: .lastUpdated)
    }
    
    public static func ==(lhs: Sublet, rhs: Sublet) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
