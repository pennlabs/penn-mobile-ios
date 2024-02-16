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
    public let expiresAt: Date
    public let subletter: Int
    public let sublettees: [String]?
    public let images: [SubletImage]

    public subscript<T>(dynamicMember keyPath: KeyPath<SubletData, T>) -> T {
        data[keyPath: keyPath]
    }

    public init(id: Int, data: SubletData, expiresAt: Date, subletter: Int, sublettees: [String]?, images: [SubletImage]) {
        self.id = id
        self.data = data
        self.expiresAt = expiresAt
        self.subletter = subletter
        self.sublettees = sublettees
        self.images = images
    }

    public init(from decoder: Decoder) throws {
        let data = try SubletData(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let expiresAt = try container.decode(Date.self, forKey: .expiresAt)
        let subletter = try container.decode(Int.self, forKey: .subletter)
        let sublettees: [String]?
        if container.contains(.sublettees) {
            sublettees = try container.decode([String]?.self, forKey: .sublettees)
        } else {
            sublettees = nil
        }
        let images = try container.decode([SubletImage].self, forKey: .images)

        self.init(id: id, data: data, expiresAt: expiresAt, subletter: subletter, sublettees: sublettees, images: images)
    }

    public enum CodingKeys: CodingKey {
        case id
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
    public var negotiable: Bool
    public var expiresAt: Date
    public var startDate: Day
    public var endDate: Day
}

public extension SubletData {
    init() {
        amenities = []
        title = ""
        address = ""
        externalLink = "https://google.com"
        price = 0
        negotiable = false
        expiresAt = Date()
        startDate = Day()
        endDate = Day()
    }
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

public extension Sublet {
    static let mock = Self(
        id: 0,
        data: .init(
            amenities: [.init(name: "Private bathroom")],
            title: "Lauder",
            address: "3650 Locust Walk",
            beds: 9,
            baths: 6.5,
            externalLink: "",
            price: 820,
            negotiable: false,
            expiresAt: .endOfSemester,
            startDate: Day(),
            endDate: Day(date: .endOfSemester)
        ),
        expiresAt: .endOfSemester,
        subletter: 123456,
        sublettees: [],
        images: [SubletImage(id: 0, imageUrl: "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bWFuc2lvbnxlbnwwfHwwfHx8MA%3D%3D")]
    )
    static let mocks = [
        mock,
        Self(
            id: 1,
            data: .init(
                amenities: [.init(name: "Balcony")],
                title: "Rittenhouse Square Studio",
                address: "2101 Market Street",
                beds: 1,
                baths: 1,
                externalLink: "",
                price: 1200,
                negotiable: true,
                expiresAt: .endOfSemester,
                startDate: Day(),
                endDate: Day(date: .endOfSemester)
            ),
            expiresAt: .endOfSemester,
            subletter: 53213,
            sublettees: [],
            images: [SubletImage(id: 1, imageUrl: "https://images.unsplash.com/photo-1560184897-ae75f418493e?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YXBhcnRtZW50fGVufDB8fDB8fHw%3D")]
        ),
        Self(
            id: 2,
            data: .init(
                amenities: [.init(name: "Gym Access"), .init(name: "Pool Access")],
                title: "Modern 2BR in Center City",
                address: "1429 Chestnut Street",
                beds: 2,
                baths: 2,
                externalLink: "",
                price: 2000,
                negotiable: true,
                expiresAt: .endOfSemester,
                startDate: Day(),
                endDate: Day(date: .endOfSemester)
            ),
            expiresAt: .endOfSemester,
            subletter: 96232,
            sublettees: [],
            images: [SubletImage(id: 2, imageUrl: "https://images.unsplash.com/photo-1494526585095-c41746248156?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YXBhcnRtZW50fGVufDB8fDB8fHw%3D")]
        ),
        Self(
            id: 3,
            data: .init(
                amenities: [.init(name: "Rooftop Access")],
                title: "Cozy Loft Near University City",
                address: "4001 Walnut Street",
                beds: 3,
                baths: 1.5,
                externalLink: "",
                price: 1500,
                negotiable: false,
                expiresAt: .endOfSemester,
                startDate: Day(),
                endDate: Day(date: .endOfSemester)
            ),
            expiresAt: .endOfSemester,
            subletter: 11923,
            sublettees: [],
            images: [SubletImage(id: 3, imageUrl: "https://images.unsplash.com/photo-1570129477492-45c003edd2be?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Y296eXxlbnwwfHwwfHx8MA%3D%3D")]
        )
    ]
}
