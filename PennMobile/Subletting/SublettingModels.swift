//
//  SublettingModels.swift
//  PennMobile
//
//  Created by Anthony Li and Jordan H on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI
import PennMobileShared

/// A sublet listing.
/// 
/// The listing's properties are split among two structs: `SubletData` and `Sublet`.
/// `SubletData` contains the properties that are set by the user when creating a listing,
/// and `Sublet` contains the remainder.
@dynamicMemberLookup
struct Sublet: Identifiable, Codable, Hashable, Sendable {
    let subletID: Int
    var data: SubletData
    var subletter: Int
    var offers: [SubletOffer]?
    var images: [SubletImage]
    
    // These are for updating the UI properly since the data can be updated without the id being updated
    var lastUpdated: Date
    var id: String {
        "\(subletID)-\(lastUpdated.timeIntervalSinceReferenceDate)"
    }

    subscript<T>(dynamicMember keyPath: KeyPath<SubletData, T>) -> T {
        data[keyPath: keyPath]
    }

    init(subletID: Int, data: SubletData, subletter: Int, offers: [SubletOffer]? = nil, images: [SubletImage], lastUpdated: Date = Date()) {
        self.subletID = subletID
        self.data = data
        self.subletter = subletter
        self.offers = offers
        self.images = images
        self.lastUpdated = lastUpdated
    }

    init(from decoder: Decoder) throws {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(subletID, forKey: .subletID)
        try data.encode(to: encoder)
        try container.encode(subletter, forKey: .subletter)
        try container.encodeIfPresent(offers, forKey: .offers)
        try container.encode(images, forKey: .images)
        try container.encode(lastUpdated, forKey: .lastUpdated)
    }
    
    static func ==(lhs: Sublet, rhs: Sublet) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@dynamicMemberLookup
struct SubletDraft: Identifiable, Codable, Hashable {
    let id: UUID
    var data: SubletData
    var images: [UIImage]
    var compressedImages = [UIImage: Data]()

    subscript<T>(dynamicMember keyPath: KeyPath<SubletData, T>) -> T {
        data[keyPath: keyPath]
    }

    init(id: UUID = UUID(), data: SubletData, images: [UIImage], compressedImages: [UIImage: Data] = [:]) {
        self.id = id
        self.data = data
        self.images = images
        self.compressedImages = compressedImages
    }

    init(from decoder: Decoder) throws {
        let data = try SubletData(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let imageData = try container.decode([Data].self, forKey: .images)
        
        var images = [UIImage]()
        var compressedImages = [UIImage: Data]()
        for imageDatum in imageData {
            if let image = UIImage(data: imageDatum) {
                images.append(image)
                compressedImages[image] = imageDatum
            }
        }
        
        self.init(id: id, data: data, images: images, compressedImages: compressedImages)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try data.encode(to: encoder)
        let imageData = images.compactMap { compressedImages[$0] ?? $0.jpegData(compressionQuality: 0.5) }
        try container.encode(imageData, forKey: .images)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case images
    }
    
    static func ==(lhs: SubletDraft, rhs: SubletDraft) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SubletData: Codable, Sendable {
    var amenities: [String]
    var title: String
    var address: String?
    var beds: Int?
    var baths: Double?
    var description: String?
    var externalLink: String? // Optional since not returned in get all sublets
    var price: Int
    var negotiable: Bool
    var expiresAt: Date? // Optional since not returned in get all sublets
    var startDate: Day
    var endDate: Day
    
    enum CodingKeys: String, CodingKey {
        case amenities, title, address, beds, baths, description, externalLink, price, negotiable, expiresAt, startDate, endDate
    }
    
    init(amenities: [String], title: String, address: String? = nil, beds: Int? = nil, baths: Double? = nil, description: String? = nil, externalLink: String? = nil, price: Int, negotiable: Bool, expiresAt: Date? = nil, startDate: Day, endDate: Day) {
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

    init(from decoder: Decoder) throws {
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
    
    func encode(to encoder: Encoder) throws {
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

extension SubletData {
    init() {
        amenities = []
        title = ""
        address = ""
        externalLink = ""
        price = 0
        negotiable = false
        expiresAt = Date()
        startDate = Day()
        endDate = Day()
    }
}

struct SubletImage: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let imageUrl: String
}

@dynamicMemberLookup
struct SubletOffer: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let createdDate: Date
    let user: Int
    let sublet: Int
    let data: SubletOfferData
    
    subscript<T>(dynamicMember keyPath: KeyPath<SubletOfferData, T>) -> T {
        data[keyPath: keyPath]
    }
    
    init(id: Int, data: SubletOfferData, createdDate: Date, user: Int, sublet: Int) {
        self.id = id
        self.data = data
        self.createdDate = createdDate
        self.user = user
        self.sublet = sublet
    }
    
    init(from decoder: Decoder) throws {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try data.encode(to: encoder)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(user, forKey: .user)
        try container.encode(sublet, forKey: .sublet)
    }

    static func ==(lhs: SubletOffer, rhs: SubletOffer) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SubletOfferData: Codable, Sendable {
    var email: String
    var phoneNumber: String
    var message: String?
}

extension SubletOfferData {
    init() {
        email = ""
        phoneNumber = ""
    }
}

extension Sublet {
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
