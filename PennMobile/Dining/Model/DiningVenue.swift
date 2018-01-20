//
//  DiningModel.swift
//  PennMobile
//
//  Created by Josh Doman on 4/23/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

enum DiningVenueType {
    case dining
    case retail
}

enum DiningVenueName: String {
    case commons = "1920 Commons"
    case mcclelland = "McClelland Express"
    case nch = "New College House"
    case hill = "Hill House"
    case english = "English House"
    case falk = "Falk Kosher Dining"
    case frontera = "Tortas Frontera"
    case gourmetGrocer = "Gourmet Grocer"
    case houston = "Houston Market"
    case joes = "Joe's Café"
    case marks = "Mark's Café"
    case beefsteak = "Beefsteak"
    case starbucks = "Starbucks"
    case unknown
    
    static func getVenueName(for apiName: String) -> DiningVenueName {
        var venueNames = DiningVenue.diningNames
        venueNames.append(contentsOf: DiningVenue.retailNames)
        for venue in venueNames {
            if apiName.contains(venue.rawValue) || venue.rawValue.contains(apiName) {
                return venue
            }
        }
        return .unknown
    }
}

class DiningVenue: NSObject {
    
    static let diningNames: [DiningVenueName] = [.commons, .mcclelland, .nch, .hill, .english, .falk]
    static let retailNames: [DiningVenueName] = [.frontera, .gourmetGrocer, .houston, .joes, .marks, .beefsteak, .starbucks]
    
    var venue: DiningVenueName
    var name: String
    var type: DiningVenueType?
    
    var times: [OpenClose]? {
        return DiningHoursData.shared.getHours(for: venue)
    }
    
    init(venue: DiningVenueName) {
        self.venue = venue
        self.name = venue.rawValue
    }
    
    static func getDefaultVenues() -> [DiningVenue] {
        return [.commons, .nch, .hill].map { DiningVenue(venue: $0) }
    }
    
    static func getVenues(for type: DiningVenueType) -> [DiningVenue] {
        let names: [DiningVenueName]
        switch type {
        case .dining:
            names = diningNames
        case .retail:
            names = retailNames
        }
        
        return names.map { DiningVenue(venue: $0) }
    }
}
