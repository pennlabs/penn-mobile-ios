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
    private var response: DiningAPIResponse = DiningAPIResponse(document: .init(venues: []))
    private let dataStore: LocalJSONStore<DiningAPIResponse> = LocalJSONStore(storageType: .cache, filename: "venues.json")

    private var todayString: String {
        return Date.dayOfMonthFormatter.string(from: Date())
    }
    
    // MARK: - Get Dining Venues (for UI)
    func getVenues() -> [DiningVenue] {
        // TODO: Implement cache fetching behavior
        return response.document.venues
    }
    
    func getSectionedVenues() -> [DiningVenue.VenueType : [DiningVenue]] {
        var venuesDict = [DiningVenue.VenueType : [DiningVenue]]()
        for type in DiningVenue.VenueType.allCases {
            venuesDict[type] = response.document.venues.filter({ $0.venueType == type })
        }
        return venuesDict
    }
    
    func getVenues(with ids: Set<Int>) -> [DiningVenue] {
        return response.document.venues.filter({ ids.contains($0.id) })
    }
    
    func getVenues(with ids: [Int]) -> [DiningVenue] {
        return response.document.venues.filter({ ids.contains($0.id) })
    }
    
    // MARK: - Cacheing
    func store(response: DiningAPIResponse) {
        self.response = response
        saveToCache(response)
    }
    
    internal func saveToCache(_ response: DiningAPIResponse) {
        // TODO: Implement cacheing behavior
        dataStore.save(response)
        
        if let storedData = dataStore.storedValue {
            dump(storedData)
        }
    }
}
