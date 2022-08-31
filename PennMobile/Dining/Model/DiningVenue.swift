//
//  DiningVenue.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct DiningVenue: Codable, Equatable, Identifiable {
    static let directory = "diningVenue-v2.json"

    let id: Int
    let name: String
    let image: URL?
    let days: [Day]

    var venueType: VenueType {
        switch id {
        case 593, 636, 637, 638, 1442, 747:
            return .dining
        default:
            return .retail
        }
    }
}

struct Day: Codable, Equatable {
    let date: String
    let meals: [Meal]

    enum CodingKeys: String, CodingKey {
        case date
        case meals = "dayparts"
    }
}

struct Meal: Codable, Equatable {
    let starttime: Date
    let endtime: Date
    let label: String
}

enum VenueType: CaseIterable {
    case dining
    case retail
}
