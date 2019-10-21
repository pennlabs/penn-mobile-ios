//
//  DiningDataStore.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class DiningDataStore {
    
    static let shared = DiningDataStore()
    private var document: DiningAPIResponse.Document = .init(venues: [])

    private var todayString: String {
        return Date.dayOfMonthFormatter.string(from: Date())
    }
    
    // MARK: - Get Dining Venues (for UI)
    func getVenues() -> [DiningVenue] {
        return document.venues
    }
    
    func getSectionedVenues() -> [DiningVenue.VenueType : [DiningVenue]] {
        var venuesDict = [DiningVenue.VenueType : [DiningVenue]]()
        for type in DiningVenue.VenueType.allCases {
            venuesDict[type] = document.venues.filter({ $0.venueType == type })
        }
        return venuesDict
    }
}
