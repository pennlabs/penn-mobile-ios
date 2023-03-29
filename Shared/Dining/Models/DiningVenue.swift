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
    static let menuUrlDict: [Int: String] = [593: "https://university-of-pennsylvania.cafebonappetit.com/cafe/1920-commons/",
                                           636: "https://university-of-pennsylvania.cafebonappetit.com/cafe/hill-house/",
                                           637: "https://university-of-pennsylvania.cafebonappetit.com/cafe/kings-court-english-house/",
                                           638: "https://university-of-pennsylvania.cafebonappetit.com/cafe/falk-dining-commons/",
                                           747: "https://university-of-pennsylvania.cafebonappetit.com/cafe/mcclelland/",
                                           1442: "https://university-of-pennsylvania.cafebonappetit.com/cafe/lauder-college-house/",
                                           639: "https://university-of-pennsylvania.cafebonappetit.com/cafe/houston-market/",
                                           641: "https://university-of-pennsylvania.cafebonappetit.com/cafe/accenture-cafe/",
                                           642: "https://university-of-pennsylvania.cafebonappetit.com/cafe/joes-cafe/",
                                           1057: "https://university-of-pennsylvania.cafebonappetit.com/cafe/1920-gourmet-grocer/",
                                           1163: "https://university-of-pennsylvania.cafebonappetit.com/cafe/1920-starbucks/",
                                           1732: "https://university-of-pennsylvania.cafebonappetit.com/cafe/pret-a-manger-upper/",
                                           1733: "https://university-of-pennsylvania.cafebonappetit.com/cafe/pret-a-manger-lower/",
                                           1464004: "https://university-of-pennsylvania.cafebonappetit.com/cafe/quaker-kitchen/",
                                           1464009: "https://university-of-pennsylvania.cafebonappetit.com/cafe/cafe-west/"]

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
