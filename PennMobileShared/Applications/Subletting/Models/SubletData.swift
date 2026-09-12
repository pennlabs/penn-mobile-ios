//
//  SubletData.swift
//  PennMobile
//
//  Created by Anthony Li on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

public struct SubletData: Codable, Sendable {
    public var amenities: [String]
    public var title: String
    public var address: String?
    public var beds: Int?
    public var baths: Double?
    public var description: String?
    public var externalLink: String?
    public var price: Int
    public var negotiable: Bool
    public var expiresAt: Date?
    public var startDate: Day
    public var endDate: Day
    
    enum CodingKeys: String, CodingKey {
        case amenities, title, address, beds, baths, description, externalLink, price, negotiable, expiresAt, startDate, endDate
    }
    
    public init(amenities: [String], title: String, address: String? = nil, beds: Int? = nil, baths: Double? = nil, description: String? = nil, externalLink: String? = nil, price: Int, negotiable: Bool, expiresAt: Date? = nil, startDate: Day, endDate: Day) {
        self.amenities = amenities
        self.title = title
        self.address = address
        self.beds = beds
        self.baths = baths
        self.description = description
        self.externalLink = externalLink
        self.price = price
        self.negotiable = negotiable
        self.expiresAt = expiresAt
        self.startDate = startDate
        self.endDate = endDate
        
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.amenities = try container.decodeIfPresent([String].self, forKey: .amenities) ?? []
        self.title = try container.decode(String.self, forKey: .title)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.beds = try container.decodeIfPresent(Int.self, forKey: .beds)
        if let bathsString = try container.decodeIfPresent(String.self, forKey: .baths) {
            self.baths = Double(bathsString)
        } else {
            self.baths = nil
        }
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.externalLink = try container.decodeIfPresent(String.self, forKey: .externalLink)
        self.price = try container.decode(Int.self, forKey: .price)
        self.negotiable = try container.decode(Bool.self, forKey: .negotiable)
        self.expiresAt = try container.decodeIfPresent(Date.self, forKey: .expiresAt)
        self.startDate = try container.decode(Day.self, forKey: .startDate)
        self.endDate = try container.decode(Day.self, forKey: .endDate)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amenities, forKey: .amenities)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(beds, forKey: .beds)
        if let baths = baths {
            try container.encode(String(baths), forKey: .baths)
        }
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(externalLink, forKey: .externalLink)
        try container.encode(price, forKey: .price)
        try container.encode(negotiable, forKey: .negotiable)
        try container.encodeIfPresent(expiresAt, forKey: .expiresAt)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
    }
}
