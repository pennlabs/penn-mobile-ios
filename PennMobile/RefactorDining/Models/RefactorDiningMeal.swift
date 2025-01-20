//
//  RefactorDiningMeal.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/13/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation


// per the notes in RefactorDiningHall: this struct conforms to both objects returned by both endpoints, as to make linking easier
public struct RefactorDiningMeal: Codable, Comparable, Hashable, Identifiable {
    public let id: Int
    public let venueId: Int
    public let stations: [RefactorDiningStation]
    public let startTime: Date
    public let endTime: Date
    public let message: String
    public let service: String
    
    
    
    // sorted by venue then by start time
    // realistically since we're using heaps this shouldn't matter all that much
    // but its going to be easier to read in debug
    public static func < (lhs: RefactorDiningMeal, rhs: RefactorDiningMeal) -> Bool {
        if (lhs.venueId == rhs.venueId) {
            return lhs.startTime < rhs.startTime
        }
        
        return lhs.venueId < rhs.venueId
    }
    public static func == (lhs: RefactorDiningMeal, rhs: RefactorDiningMeal) -> Bool {
        lhs.venueId == rhs.venueId && (lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime)
    }
}

public struct RefactorDiningStation: Codable, Hashable {
    let idVert = UUID()
    let idHoriz = UUID()
    let id = UUID()
    let name: String
    let items: [RefactorDiningItem]
    
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
    public static func getWeight(station: RefactorDiningStation) -> Int {
        let (weight, _) = dictionary[station.name.lowercased()] ?? (50, 1)
        return weight
        
    }
    
}

public struct RefactorDiningItem: Codable, Identifiable, Hashable {
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
}




public extension RefactorDiningItem {
    func getAllergens() -> [RefactorDiningAllergen] {
        let allergens: [RefactorDiningAllergen] = self.allergens.split(usingRegex: #",\s*"#).map { el in
            
            for allergen in RefactorDiningAllergen.allCases {
                if el == allergen.rawValue {
                    return allergen
                }
            }
            return .other
        }.filter({$0 != RefactorDiningAllergen.other})
        
        return allergens
    }
    
    
    func getAllergenImages() -> [String] {
        let allergens = getAllergens()
        return allergens.map { el in
            el.imagePath
        }
    }
}


public enum RefactorDiningAllergen: String, CaseIterable {
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
