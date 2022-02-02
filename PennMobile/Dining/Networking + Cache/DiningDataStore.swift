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

    /// Returns the same venues in the same order with updated hours
    func getVenues(for venueIDs: [Int]) -> [DiningVenue] {
        let idSet = Set(venueIDs)
        let unsortedUpdatedVenues = getVenues().filter { idSet.contains($0.id) }
        var sortedUpdatedVenues = [DiningVenue]()
        for venueID in venueIDs {
            if let updatedVenue = unsortedUpdatedVenues.filter({ $0.id == venueID }).first {
                sortedUpdatedVenues.append(updatedVenue)
            }
        }
        return sortedUpdatedVenues
    }

    func getSectionedVenues() -> [DiningVenue.VenueType: [DiningVenue]] {
        var venuesDict = [DiningVenue.VenueType: [DiningVenue]]()
        for type in DiningVenue.VenueType.allCases {
            venuesDict[type] = getVenues().filter({ $0.venueType == type })
        }
        return venuesDict
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
