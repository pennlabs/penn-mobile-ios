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

public struct RefactorDiningStation: Codable, Hashable, Identifiable {
    public let id = UUID()
    let name: String
    let items: [RefactorDiningItem]
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
