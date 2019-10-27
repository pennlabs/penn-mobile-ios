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
    
    private init() {
        _ = self.getVenues()
    }
    
    // MARK: - Get Dining Venues (for UI)
    func getVenues() -> [DiningVenue] {
        if response.document.venues.isEmpty {
            if let cachedResponse = dataStore.storedValue {
                self.response = cachedResponse
                return cachedResponse.document.venues
            }
        }
        return response.document.venues
    }
    
    func getSectionedVenues() -> [DiningVenue.VenueType : [DiningVenue]] {
        var venuesDict = [DiningVenue.VenueType : [DiningVenue]]()
        for type in DiningVenue.VenueType.allCases {
            venuesDict[type] = getVenues().filter({ $0.venueType == type })
        }
        return venuesDict
    }
    
    func getVenues(with ids: Set<Int>) -> [DiningVenue] {
        return getVenues().filter({ ids.contains($0.id) })
    }
    
    func getVenues(with ids: [Int]) -> [DiningVenue] {
        return getVenues().filter({ ids.contains($0.id) })
    }
    
    // MARK: - Cacheing
    func store(response: DiningAPIResponse) {
        self.response = response
        saveToCache(response)
    }
    
    internal func saveToCache(_ response: DiningAPIResponse) {
        dataStore.save(response)
    }
}
