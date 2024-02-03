//
//  SublettingModels.swift
//  PennMobile
//
//  Created by Anthony Li and Jordan H on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

/// A sublet listing.
/// 
/// The listing's properties are split among two structs: `SubletData` and `Sublet`.
/// `SubletData` contains the properties that are set by the user when creating a listing,
/// and `Sublet` contains the remainder.
@dynamicMemberLookup
public struct Sublet: Identifiable, Decodable {
    public let id: Int
    public let data: SubletData
    public let createdAt: Date
    public let expiresAt: Date
    public let subletter: String
    public let sublettees: [String]
    public let images: [SubletImage]

    public subscript<T>(dynamicMember keyPath: KeyPath<SubletData, T>) -> T {
        data[keyPath: keyPath]
    }

    public init(id: Int, data: SubletData, createdAt: Date, expiresAt: Date, subletter: String, sublettees: [String], images: [SubletImage]) {
        self.id = id
        self.data = data
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.subletter = subletter
        self.sublettees = sublettees
        self.images = images
    }

    public init(from decoder: Decoder) throws {
        let data = try SubletData(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let createdAt = try container.decode(Date.self, forKey: .createdAt)
        let expiresAt = try container.decode(Date.self, forKey: .expiresAt)
        let subletter = try container.decode(String.self, forKey: .subletter)
        let sublettees = try container.decode([String].self, forKey: .sublettees)
        let images = try container.decode([SubletImage].self, forKey: .images)

        self.init(id: id, data: data, createdAt: createdAt, expiresAt: expiresAt, subletter: subletter, sublettees: sublettees, images: images)
    }

    public enum CodingKeys: CodingKey {
        case id
        case createdAt
        case expiresAt
        case subletter
        case sublettees
        case images
    }
}

public struct SubletData: Codable {
    public var amenities: [SubletAmenity]
    public var title: String
    public var address: String
    public var beds: Int?
    public var baths: Double?
    public var description: String?
    public var externalLink: String
    public var price: Int
    public var expiresAt: Date
    public var startDate: Date
    public var endDate: Date
}

public struct SubletAmenity: Codable {
    public let name: String
}

public struct SubletImage: Decodable {
    public let id: Int
    public let imageUrl: String
}

@dynamicMemberLookup
public struct SubletOffer: Identifiable, Decodable {
    public let id: Int
    public let data: SubletOfferData
    
    public subscript<T>(dynamicMember keyPath: KeyPath<SubletOfferData, T>) -> T {
        data[keyPath: keyPath]
    }
    
    public init(id: Int, data: SubletOfferData) {
        self.id = id
        self.data = data
    }
    
    public init(from decoder: Decoder) throws {
        let data = try SubletOfferData(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        
        self.init(id: id, data: data)
    }
    
    public enum CodingKeys: CodingKey {
        case id
    }
}

public struct SubletOfferData: Codable {
    public var email: String
    public var phoneAddress: String
    public var message: String
}
