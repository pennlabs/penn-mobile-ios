//
//  DiningVenue.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct DiningVenue: Codable, Equatable, Identifiable {
    
    static let directory = "diningVenue.json"
    
    let id: Int
    let name: String
    let venueType: VenueType
    let facilityURL: URL?
    let imageURL: URL?
    let meals: [String: MealsForDate]
    
    struct MealsForDate: Codable, Equatable {
        let date: String
        let meals: [Meal]
        
        struct Meal: Codable, Equatable {
            let open: Date
            let close: Date
            let type: String
        }
    }
    
    enum VenueType: String, Codable, CaseIterable {
        case dining = "residential"
        case retail = "retail"
        case unknown = "unknown"
    }
}
