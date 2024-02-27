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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.venueInfo = try container.decode(VenueInfo.self, forKey: .venueInfo)
        self.date = try container.decode(Date.self, forKey: .date)
        self.startTime = try container.decode(String.self, forKey: .startTime)
        self.endTime = try container.decode(String.self, forKey: .endTime)
        self.service = try container.decode(String.self, forKey: .service)
        
        self.stations = try container.decode([DiningStation].self, forKey: .stations).sorted {
            if (DiningStation.getWeight(station: $0) == DiningStation.getWeight(station: $1)) {
                return $0.name > $1.name
            }
            return DiningStation.getWeight(station: $0) < DiningStation.getWeight(station: $1)
        }
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
    public let vertUID: UUID
    public let horizUID: UUID
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.items = try container.decode([DiningStationItem].self, forKey: .items)
        self.vertUID = UUID()
        self.horizUID = UUID()
    }

    public enum CodingKeys: String, CodingKey {
        case name
        case items
    }
    
    public static func getWeight(station: DiningStation) -> Int {
        let dictionary: [String:Int] = [
            // 1-10 Specials
            "chef's table":1,
            "special events":2,
            "expo":3,
            "expo toppings":4,
            "feature entree":5,
            "vegan feature entrée":6,
            "smoothie bar":7,
            "cafe specials":8,
            
            
            // 11-25 Larger Entree Stations
            "grill": 11,
            "vegan grill": 12,
            "pennsburg grill": 13,
            "hill grill lunch": 14,
            "hill grill lunch sides": 15,
            "smoque'd deli": 16,
            "pizza": 17,
            "flatbread": 18,
            
            //26 - 49 Smaller Entrees
            "salad bar": 26,
            "salads": 27,
            "insalata": 28,
            "catch": 29,
            "breakfast bar": 30,
            "breakfast": 31,
            "rise and dine": 32,
            "global fusion": 33,
            "global fusion sides": 34,
            "near & far": 35,
            "mezze": 36,
            "grotto":37,
            "simplyoasis": 38,
            "simplyoasis sides": 39,
            "comfort": 40,
            "melts": 41,
            
            // 50 IS THE DEFAULT
            
            // 51 - 60 Sides
            "kettles": 51,
            "fruit plus": 52,
            "hand fruit": 53,
            "fruit & yogurt": 54,
            "fruit and yogurt": 55,
            "breads and bagels": 56,
            "breads and toast": 57,
            "cereal": 58,
            
            // 61 - 65 Desserts
            "sweets & treats": 61,
            "sweets and treats": 62,
            "ice cream": 63,
            "ice cream bar": 64,
            "dessert": 65,
            
            // 66 - 70 Assorted Toppings
            "condiments": 66,
            "on the side": 67,
            "dairy comfort": 68,
            "flavors": 69,
            "vegan flavors": 70,
            
            // 71 - 75 Drinks
            "beverages": 71,
            "coffee": 72
        ]
        
        return dictionary[station.name.lowercased()] ?? 50
        
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
