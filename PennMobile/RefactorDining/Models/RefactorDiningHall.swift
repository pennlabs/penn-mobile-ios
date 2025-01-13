//
//  RefactorDiningHall.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/13/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import Foundation


/*
 Ok so current thought:
 
 1. The dining hall schedule (meal schedule) is in the venues endpoint, which also contains the name, address, etc (fields in DiningHall).
 2. The actual items in each meal are in the menus endpoint. This makes it really difficult to link between the two.
    2a. So I don't think I'm going to. That is, I'm going to link the two endpoints' data together as they're initialized.
 3. On init, we will create (because CIS-1210 just ended and I want to justify a semester of pain) a heap of containing DiningHall objects (keyed by date)
    and an a heap of DiningMenu objects keyed by date.
        3a. O(n)
 4. We will then iterate through each heap, popping both minimums off the heap if they are equal (linking the two together).
    If not equal, pop the smaller of the two (indicating that we have no data for the meal we just removed) and continue.
        4a. O(nlogn)
 5. In theory, we should run out of data in both heaps at the same time.
 6. Then cache the whole data structure. (probably expensive given its like 200,000 lines)
 */

struct RefactorDiningHall: Codable, Identifiable {
    let name: String
    let address: String
    let schedule: [RefactorDiningDay]
    let imageUrl: URL
    let id: Int
    
    
    enum CodingKeys: String, CodingKey {
        case name
        case address
        case schedule = "days"
        case imageUrl = "image"
        case id
    }
}

struct RefactorDiningDay: Codable {
    let date: Date
    let open: Bool
    let meals: [RefactorDiningMeal]
    
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let date = try values.decodeIfPresent(Date.self, forKey: .date) else {
            throw DecodingError.valueNotFound(Date.self, DecodingError.Context(codingPath: [CodingKeys.date], debugDescription: "Date not found."))
        }
        guard let open = try values.decodeIfPresent(Bool.self, forKey: .open) else {
            throw DecodingError.valueNotFound(Bool.self, DecodingError.Context(codingPath: [CodingKeys.open], debugDescription: "Status not found."))
        }
        guard let meals = try values.decodeIfPresent([RefactorDiningMeal].self, forKey: .meals) else {
            throw DecodingError.valueNotFound([RefactorDiningMeal].self, DecodingError.Context(codingPath: [CodingKeys.meals], debugDescription: "Meals not found."))
        }
        
        self.date = date
        self.open = open
        self.meals = meals
        
    }
    
    enum CodingKeys: String, CodingKey {
        case date
        case open = "status"
        case meals = "dayparts"
    }
}

struct RefactorDiningMeal: Codable {
    
}


