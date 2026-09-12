//
//  SubletOffer.swift
//  PennMobile
//
//  Created by Anthony Li on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

@dynamicMemberLookup
public struct SubletOffer: Identifiable, Codable, Hashable, Sendable {
    public let id: Int
    public let createdDate: Date
    public let user: Int
    public let sublet: Int
    public let data: SubletOfferData
    
    public subscript<T>(dynamicMember keyPath: KeyPath<SubletOfferData, T>) -> T {
        data[keyPath: keyPath]
    }
    
    public init(id: Int, data: SubletOfferData, createdDate: Date, user: Int, sublet: Int) {
        self.id = id
        self.data = data
        self.createdDate = createdDate
        self.user = user
        self.sublet = sublet
    }
    
    public init(from decoder: Decoder) throws {
        let data = try SubletOfferData(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let createdDate = try container.decode(Date.self, forKey: .createdDate)
        let user = try container.decode(Int.self, forKey: .user)
        let sublet = try container.decode(Int.self, forKey: .sublet)
        
        self.init(id: id, data: data, createdDate: createdDate, user: user, sublet: sublet)
    }
    
    enum CodingKeys: CodingKey {
        case id
        case createdDate
        case user
        case sublet
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try data.encode(to: encoder)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(user, forKey: .user)
        try container.encode(sublet, forKey: .sublet)
    }

    public static func ==(lhs: SubletOffer, rhs: SubletOffer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
