//
//  DiningMenu.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 26/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

struct MenuList: Codable {
    static let directory = "diningMenus.json"

    let menus: [DiningMenu]
}

struct DiningMenu: Codable, Hashable {
    let venueInfo: VenueInfo
    let date: Date
    let startTime: String
    let endTime: String
    let stations: [DiningStation]
    let service: String

    enum CodingKeys: String, CodingKey {
        case venueInfo = "venue"
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case stations
        case service
    }
}

struct VenueInfo: Codable, Hashable {
    let id: Int
    let name: String
    let image: String
    
    enum CodingKeys: String, CodingKey {
        case id = "venue_id"
        case name
        case image = "image_url"
    }
}

struct DiningStation: Codable, Hashable {
    let name: String
    let items: [DiningStationItem]

    enum CodingKeys: String, CodingKey {
        case name
        case items
    }
}

struct DiningStationItem: Codable, Hashable {
    let id: Int
    let name: String
    let desc: String
    let ingredients: String

    enum CodingKeys: String, CodingKey {
        case id = "item_id"
        case name
        case desc = "description"
        case ingredients
    }
}
