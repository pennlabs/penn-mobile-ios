//
//  DiningMenu.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 26/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

public struct MenuList: Codable {
    public static let directory = "diningMenus.json"

    public let menus: [DiningMenu]
    
    public init(menus: [DiningMenu]) {
        self.menus = menus
    }
}

public struct DiningMenu: Codable, Hashable {
    public let venueInfo: VenueInfo
    public let date: Date
    public let startTime: String
    public let endTime: String
    public let stations: [DiningStation]
    public let service: String

    public enum CodingKeys: String, CodingKey {
        case venueInfo = "venue"
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case stations
        case service
    }
}

public struct VenueInfo: Codable, Hashable {
    public let id: Int
    public let name: String
    public let image: String
    
    public enum CodingKeys: String, CodingKey {
        case id = "venue_id"
        case name
        case image = "image_url"
    }
}

public struct DiningStation: Codable, Hashable {
    public let name: String
    public let items: [DiningStationItem]

    public enum CodingKeys: String, CodingKey {
        case name
        case items
    }
}

public struct DiningStationItem: Codable, Hashable {
    public let id: Int
    public let name: String
    public let desc: String
    public let ingredients: String

    public enum CodingKeys: String, CodingKey {
        case id = "item_id"
        case name
        case desc = "description"
        case ingredients
    }
}
