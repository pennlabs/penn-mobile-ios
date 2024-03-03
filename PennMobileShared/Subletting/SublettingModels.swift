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
public struct Sublet: Identifiable, Decodable, Hashable {
    public let subletID: Int
    public let data: SubletData
    public let subletter: Int
    public var offers: [SubletOffer]?
    public var images: [SubletImage]
    
    // These are for updating the UI properly since the data can be updated without the id being updated
    public let lastUpdated: Date
    public var id: String {
        "\(subletID)-\(lastUpdated.timeIntervalSinceReferenceDate)"
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<SubletData, T>) -> T {
        data[keyPath: keyPath]
    }

    public init(subletID: Int, data: SubletData, subletter: Int, offers: [SubletOffer]? = nil, images: [SubletImage]) {
        self.subletID = subletID
        self.data = data
        self.subletter = subletter
        self.offers = offers
        self.images = images
        self.lastUpdated = Date()
    }

    public init(from decoder: Decoder) throws {
        let data = try SubletData(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let subletID = try container.decode(Int.self, forKey: .subletID)
        let subletter = try container.decode(Int.self, forKey: .subletter)
        let images = try container.decode([SubletImage].self, forKey: .images)
        
        self.init(subletID: subletID, data: data, subletter: subletter, images: images)
    }

    public enum CodingKeys: String, CodingKey {
        case subletID = "id"
        case subletter
        case images
    }
    
    public static func ==(lhs: Sublet, rhs: Sublet) -> Bool {
        return lhs.subletID == rhs.subletID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(subletID)
    }
}

public struct SubletData: Codable {
    public var amenities: [String]
    public var title: String
    public var address: String?
    public var beds: Int?
    public var baths: Double?
    public var description: String?
    public var externalLink: String? // Optional since not returned in get all sublets
    public var price: Int
    public var negotiable: Bool
    public var expiresAt: Date? // Optional since not returned in get all sublets
    public var startDate: Day
    public var endDate: Day
    
    enum CodingKeys: String, CodingKey {
        case amenities, title, address, beds, baths, description, externalLink, price, negotiable, expiresAt, startDate, endDate
    }

    enum AmenityCodingKeys: String, CodingKey {
        case name
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
        
        self.title = try container.decode(String.self, forKey: .title)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.beds = try container.decodeIfPresent(Int.self, forKey: .beds)
        self.baths = try container.decodeIfPresent(Double.self, forKey: .baths)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.externalLink = try container.decodeIfPresent(String.self, forKey: .externalLink)
        self.price = try container.decode(Int.self, forKey: .price)
        self.negotiable = try container.decode(Bool.self, forKey: .negotiable)
        self.expiresAt = try container.decodeIfPresent(Date.self, forKey: .expiresAt)
        self.startDate = try container.decode(Day.self, forKey: .startDate)
        self.endDate = try container.decode(Day.self, forKey: .endDate)

        var amenitiesContainer = try container.nestedUnkeyedContainer(forKey: .amenities)
        var amenitiesNames: [String] = []
        while !amenitiesContainer.isAtEnd {
            let amenityContainer = try amenitiesContainer.nestedContainer(keyedBy: AmenityCodingKeys.self)
            let name = try amenityContainer.decode(String.self, forKey: .name)
            amenitiesNames.append(name)
        }
        self.amenities = amenitiesNames
    }
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

public struct SubletImage: Decodable {
    public let id: Int
    public let imageUrl: String
}

@dynamicMemberLookup
public struct SubletOffer: Identifiable, Decodable, Hashable {
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
    
    public enum CodingKeys: CodingKey {
        case id
        case createdDate
        case user
        case sublet
    }

    public static func ==(lhs: SubletOffer, rhs: SubletOffer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct SubletOfferData: Codable {
    public var email: String
    public var phoneNumber: String
    public var message: String?
}

public extension SubletOfferData {
    init() {
        email = ""
        phoneNumber = ""
    }
}

public extension Sublet {
    static let mock = Self(
        subletID: 0,
        data: .init(
            amenities: ["Private bathroom"],
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
        subletter: 123456,
        offers: [SubletOffer(
            id: 0,
            data: .init(email: "fake@email.com", phoneNumber: "+1234567890", message: "I am interested!"),
            createdDate: Date(),
            user: 0,
            sublet: 0
        ), SubletOffer(
            id: 1,
            data: .init(email: "hello@world.com", phoneNumber: "+1098765432"),
            createdDate: Date(),
            user: 1,
            sublet: 0)
        ],
        images: [SubletImage(id: 0, imageUrl: "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bWFuc2lvbnxlbnwwfHwwfHx8MA%3D%3D")]
    )
    static let mocks = [
        mock,
        Self(
            subletID: 1,
            data: .init(
                amenities: ["Balcony"],
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
            subletter: 53213,
            images: [SubletImage(id: 1, imageUrl: "https://images.unsplash.com/photo-1560184897-ae75f418493e?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YXBhcnRtZW50fGVufDB8fDB8fHw%3D")]
        ),
        Self(
            subletID: 2,
            data: .init(
                amenities: ["Gym Access", "Pool Access"],
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
            subletter: 96232,
            images: [SubletImage(id: 2, imageUrl: "https://images.unsplash.com/photo-1494526585095-c41746248156?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YXBhcnRtZW50fGVufDB8fDB8fHw%3D")]
        ),
        Self(
            subletID: 3,
            data: .init(
                amenities: ["Rooftop Access"],
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
            subletter: 11923,
            images: [SubletImage(id: 3, imageUrl: "https://images.unsplash.com/photo-1570129477492-45c003edd2be?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Y296eXxlbnwwfHwwfHx8MA%3D%3D")]
        )
    ]
}
