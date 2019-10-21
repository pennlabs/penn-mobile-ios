//
//  DiningVenueName.swift
//  PennMobile
//
//  Created by Josh Doman on 2/21/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

/*import Foundation

enum DiningVenueName: String {
    case commons =       "1920 Commons"
    case mcclelland =    "McClelland Express"
    case lauder =        "Lauder College House"
    case hill =          "Hill House"
    case english =       "English House"
    case falk =          "Falk Kosher Dining"
    case gourmetGrocer = "1920 Gourmet Grocer"
    case houston =       "Houston Market"
    case joes =          "Joe's Café"
    case starbucks =     "1920 Starbucks"
    case pret =          "Pret a Manger Locust Walk"
    case mbaCafe =       "Pret a Manger MBA"
    case unknown
    
    static func getShortVenueName(for venueName: DiningVenueName) -> String {
        switch venueName {
        case lauder:               return "Lauder"
        case mcclelland:        return "McClelland"
        case falk:              return "Falk Kosher"
        case commons:           return "Commons"
        case english:           return "English"
        case gourmetGrocer:     return "G. Grocer"
        case houston:           return "Houston"
        case pret:              return "Pret"
        case mbaCafe:           return "MBA Cafe"
        default:                return venueName.rawValue
        }
    }
    
    static func getVenueName(for venueName: DiningVenueName) -> String {
        return venueName.rawValue
    }
    
    static func getVenueName(for apiName: String) -> DiningVenueName {
        if apiName.contains("MBA") {
            return .mbaCafe
        }
        
        var venueNames = DiningVenue.diningNames
        venueNames.append(contentsOf: DiningVenue.retailNames)
        for venue in venueNames {
            if apiName.contains(venue.rawValue) || venue.rawValue.contains(apiName) {
                return venue
            }
        }
        return .unknown
    }
    
    static func getType(for venue: DiningVenueName) -> DiningVenueType {
        if venue == .commons || venue == .english || venue == .falk || venue == .hill || venue == .lauder || venue == .mcclelland {
            return .dining
        } else {
            return .retail
        }
    }
    
    func getID() -> Int {
        switch self {
        case .commons:
            return 593
        case .mcclelland:
            return 747
        case .lauder:
            return 1442
        case .hill:
            return 636
        case .english:
            return 637
        case .falk:
            return 638
        case .gourmetGrocer:
            return 1057
        case .houston:
            return 639
        case .joes:
            return 642
        case .starbucks:
            return 1163
        case .pret:
            return 1733
        case .mbaCafe:
            return 1732
        case .unknown:
            return -1
        }
    }
    
    static let idDict: [Int: DiningVenueName] = [
        593: .commons,
        747: .mcclelland,
        1442: .lauder,
        636: .hill,
        637: .english,
        638: .falk,
        639: .houston,
        642: .joes,
        1163: .starbucks,
        1733: .pret,
        1732: .mbaCafe,
    ]
}
*/
