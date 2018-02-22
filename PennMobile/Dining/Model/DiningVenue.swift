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

class DiningVenue: NSObject {
    
    static let diningNames: [DiningVenueName] = [.commons, .mcclelland, .nch, .hill, .english, .falk]
    static let retailNames: [DiningVenueName] = [.frontera, .gourmetGrocer, .houston, .joes, .marks, .beefsteak, .starbucks, .pret, .mbaCafe]
    
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
