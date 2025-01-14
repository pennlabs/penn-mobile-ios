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
