//
//  RefactorDiningMeal.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/13/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation


// per the notes in RefactorDiningHall: this struct conforms to both objects returned by both endpoints, as to make linking easier
struct RefactorDiningMeal: Codable, Comparable {
    let id: Int
    let venueId: Int
    let stations: [RefactorDiningStation]
    let startTime: Date
    let endTime: Date
    let message: String
    let service: String
    
    
    
    // sorted by venue then by start time
    // realistically since we're using heaps this shouldn't matter all that much
    // but its going to be easier to read in debug
    static func < (lhs: RefactorDiningMeal, rhs: RefactorDiningMeal) -> Bool {
        if (lhs.venueId == rhs.venueId) {
            return lhs.startTime < rhs.startTime
        }
        
        return lhs.venueId < rhs.venueId
    }
    static func == (lhs: RefactorDiningMeal, rhs: RefactorDiningMeal) -> Bool {
        lhs.venueId == rhs.venueId && (lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime)
    }
}

struct RefactorDiningStation: Codable {
    let name: String
    let items: [RefactorDiningItem]
}

struct RefactorDiningItem: Codable, Identifiable {
    // this field used to conform to Identifiable without the use of CodingKeys
    var id: Int {
        itemId
    }
    
    let itemId: Int
    let nutritionInfo: [String : String]
    let name: String
    let description: String
    let ingredients: String
    let allergens: String
}
