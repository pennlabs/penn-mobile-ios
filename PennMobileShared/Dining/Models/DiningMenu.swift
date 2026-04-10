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
    public let startTime: Date
    public let endTime: Date
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
        
        let formatter = ISO8601DateFormatter()
        let start = try container.decode(String.self, forKey: .startTime)
        let end = try container.decode(String.self, forKey: .endTime)
        self.startTime = try formatter.date(from: start).unwrap(orThrow: DecodingError.typeMismatch(Date.self, .init(codingPath: [CodingKeys.startTime], debugDescription: "Unable to decode start time for meal")))
        self.endTime = try formatter.date(from: end).unwrap(orThrow: DecodingError.typeMismatch(Date.self, .init(codingPath: [CodingKeys.endTime], debugDescription: "Unable to decode start time for meal")))
        self.service = try container.decode(String.self, forKey: .service)
        
        self.stations = try container.decode([DiningStation].self, forKey: .stations).sorted {
            if (DiningStation.getWeight(station: $0) == DiningStation.getWeight(station: $1)) {
                return $0.name > $1.name
            }
            return DiningStation.getWeight(station: $0) < DiningStation.getWeight(station: $1)
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(venueInfo, forKey: .venueInfo)
        try container.encode(date, forKey: .date)
        try container.encode(service, forKey: .service)
        try container.encode(stations, forKey: .stations)
        let formatter = ISO8601DateFormatter()
        let startStr = formatter.string(from: startTime)
        let endStr = formatter.string(from: endTime)
        try container.encode(startStr, forKey: .startTime)
        try container.encode(endStr, forKey: .endTime)
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
    
    // Dictionary is (Int, Int), (Weight, Number of Columns)
    public static let dictionary: [String:(Int,Int)] = [
        // 1-10 Specials
        "chef's table":(1,1),
        "special events":(2,1),
        "expo":(3,1),
        "expo toppings":(4,2),
        "feature entree":(5,1),
        "vegan feature entrée":(6,1),
        "smoothie bar":(7,2),
        "cafe specials":(8,1),
        
        
        // 11-25 Larger Entree Stations
        "grill": (11,1),
        "vegan grill": (12,1),
        "pennsburg grill": (13,1),
        "hill grill lunch": (14,1),
        "hill grill lunch sides": (15,2),
        "smoque'd deli": (16,2),
        "pizza": (17,1),
        "flatbread": (18,1),
        "simplyoasis": (19,1),
        "simplyoasis sides": (20,2),
        "global fusion": (21,1),
        "global fusion sides": (22,2),
        
        //26 - 49 Smaller Entrees
        "salad bar": (26,2),
        "salads": (27,2),
        "insalata": (28,1),
        "catch": (29,1),
        "breakfast bar": (30,2),
        "breakfast": (31,1),
        "rise and dine": (32,1),
        "near & far": (33,1),
        "mezze": (34,2),
        "grotto":(35,1),
        "comfort": (36,1),
        "melts": (37,1),
        
        // 50 IS THE DEFAULT
        
        // 51 - 60 Sides
        "kettles": (51,1),
        "fruit plus": (52,2),
        "hand fruit": (53,2),
        "fruit & yogurt": (54,2),
        "fruit and yogurt": (55,2),
        "breads and bagels": (56,2),
        "breads and toast": (57,2),
        "cereal": (58,2),
        
        // 61 - 65 Desserts
        "sweets & treats": (61,2),
        "sweets and treats": (62,2),
        "ice cream": (63,2),
        "ice cream bar": (64,2),
        "dessert": (65,1),
        
        // 66 - 70 Assorted Toppings
        "condiments": (66,2),
        "on the side": (67,2),
        "dairy comfort": (68,2),
        "flavors": (69,2),
        "vegan flavors": (70,2),
        
        // 71 - 75 Drinks
        "beverages": (71,2),
        "coffee": (72,1)
    ]
    
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
        let (weight, _) = dictionary[station.name.lowercased()] ?? (50, 1)
        return weight
        
    }
    
    public static func getColumns(station: DiningStation) -> Int {
        let (_, cols) = dictionary[station.name.lowercased()] ?? (50, 1)
        return cols
        
    }
    
    
    
}

public struct DiningStationItem: Codable, Identifiable, Hashable {
    // this field used to conform to Identifiable without the use of CodingKeys
    public var id: Int {
        itemId
    }
    
    public let itemId: Int
    public let nutritionInfo: [String : String]
    public let name: String
    public let description: String
    public let ingredients: String
    public let allergens: String
    
    enum CodingKeys: String, CodingKey {
        // Manually converting from snake case because I didn't want to deal with global decoder issues
        case itemId = "item_id"
        case nutritionInfo = "nutrition_info"
        case name, description, ingredients, allergens
    }
}




public extension DiningStationItem {
    func getAllergens() -> [DiningAllergen] {
        let allergens: [DiningAllergen] = self.allergens.split(separator: #",\s*"#).map { el in
            for allergen in DiningAllergen.allCases {
                if el == allergen.rawValue {
                    return allergen
                }
            }
            return .other
        }.filter({$0 != DiningAllergen.other})
        
        return allergens
    }
    
    
    func getAllergenImages() -> [String] {
        let allergens = getAllergens()
        return allergens.map { el in
            el.imagePath
        }
    }
}


public enum DiningAllergen: String, CaseIterable {
        case seafoodWatch = "Seafood Watch"
        case sesame = "Sesame"
        case fish = "Fish"
        case soy = "Soy"
        case egg = "Egg"
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case farmToFork = "Farm to Fork"
        case humane = "Humane"
        case locallyCrafted = "Locally Crafted"
        case peanut = "Peanut"
        case treeNut = "Tree Nut"
        case wheatGluten = "Wheat/Gluten"
        case milk = "Milk"
        case askUs = "Ask Us"
        case other
    
    
    
    var imagePath: String {
        switch self {
        case .seafoodWatch:
            return "Seafood Watch"
        case .sesame:
            return "Sesame"
        case .fish:
            return "Fish"
        case .soy:
            return "Soy"
        case .egg:
            return "Egg"
        case .vegetarian:
            return "Vegetarian"
        case .vegan:
            return "Vegan"
        case .farmToFork:
            return "Farm to Fork"
        case .humane:
            return "Humane"
        case .locallyCrafted:
            return "Locally Crafted"
        case .peanut:
            return "Peanut"
        case .treeNut:
            return "Tree Nut"
        case .wheatGluten:
            return "Wheat"
        case .milk:
            return "Milk"
        case .askUs:
            return "Ask Us"
        case .other:
            return ""
        }
    }
}
