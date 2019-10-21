//
//  DiningVenue.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct DiningVenue: Codable {
    
    let id: Int
    let name: String
    let venueType: VenueType
    let facilityURL: URL?
    let meals: [String: MealsForDate]?
    
    struct MealsForDate: Codable {
        let date: String
        let meals: [Meal]
        
        struct Meal: Codable {
            let open: Date
            let close: Date
            let type: String
        }
    }
    
    enum VenueType: String, Codable {
        case dining = "residential"
        case retail = "retail"
        case unknown = "unknown"
    }
}
