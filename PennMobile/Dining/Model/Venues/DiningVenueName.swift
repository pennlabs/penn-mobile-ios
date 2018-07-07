//
//  DiningVenueName.swift
//  PennMobile
//
//  Created by Josh Doman on 2/21/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

enum DiningVenueName: String {
    case commons =       "1920 Commons"
    case mcclelland =    "McClelland"
    case nch =           "NCH Dining"
    case hill =          "Hill House"
    case english =       "English House"
    case falk =          "Falk Kosher"
    case frontera =      "Tortas Frontera"
    case gourmetGrocer = "Gourmet Grocer"
    case houston =       "Houston Market"
    case joes =          "Joe's Café"
    case marks =         "Mark's Café"
    case beefsteak =     "Beefsteak"
    case starbucks =     "Starbucks"
    case pret =          "Pret a Manger"
    case mbaCafe =       "MBA Café"
    case unknown
    
    static func getShortVenueName(for venueName: DiningVenueName) -> String {
        switch venueName {
        case commons:           return "Commons"
        case english:           return "English"
        case frontera:          return "Frontera"
        case gourmetGrocer:     return "G. Grocer"
        case houston:           return "Houston"
        case pret:              return "Pret"
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
    
    func getID() -> Int {
        switch self {
        case .commons:
            return 593
        case .mcclelland:
            return 747
        case .nch:
            return 1442
        case .hill:
            return 636
        case .english:
            return 637
        case .falk:
            return 638
        case .frontera:
            return 1058
        case .gourmetGrocer:
            return 1057
        case .houston:
            return 639
        case .joes:
            return 642
        case .marks:
            return 640
        case .beefsteak:
            return 1441
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
}
