//
//  DiningViewModelSwiftUI.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 4/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

class DiningViewModelSwiftUI: ObservableObject {
    static let instance = DiningViewModelSwiftUI()

    @Published var diningVenues: [VenueType: [DiningVenue]] = DiningAPI.instance.getSectionedVenues()
    @Published var favoriteVenues: [DiningVenue] = []
    
    @Published var diningMenus = DiningAPI.instance.getMenus()

    @Published var diningVenuesIsLoading = false
    @Published var alertType: NetworkingError?

    @Published var diningBalance = (try? Storage.retrieveThrowing(DiningBalance.directory, from: .groupCaches, as: DiningBalance.self)) ?? DiningBalance(date: Date.dayOfMonthFormatter.string(from: Date()), diningDollars: "0.0", regularVisits: 0, guestVisits: 0, addOnVisits: 0)
    // MARK: - Venue Methods
    let ordering: [VenueType] = [.dining, .retail]

    func refreshVenues() async {
        let lastRequest = UserDefaults.standard.getLastDiningHoursRequest()
        // Sometimes when building the app, dining venue list is empty, but because it has refreshed within the day, it does not refresh again. Now, refreshes if the list of venues is completely empty
        if lastRequest == nil || !lastRequest!.isToday || diningVenues.isEmpty {
            self.diningVenuesIsLoading = true
            let diningResult = await DiningAPI.instance.fetchDiningHours()
//            let favoritesResult = await UserDBManager.shared.fetchDiningPreferences()
            
            switch diningResult {
            case .success(let diningVenues):
                UserDefaults.standard.setLastDiningHoursRequest()
                var venuesDict = [VenueType: [DiningVenue]]()
                for type in VenueType.allCases {
                    venuesDict[type] = diningVenues.filter({ $0.venueType == type })// && !favoritesResult.contains($0) })
                }
                
                let favoritesIDs = UserDefaults(suiteName: Storage.appGroupID)?.array(forKey: "diningFavorites") as? [Int] ?? []
                var favorites: [DiningVenue?] = []
                for id in favoritesIDs {
                    favorites.append(venuesDict[.dining]?.first(where: { $0.id == id }) ?? venuesDict[.retail]?.first(where: { $0.id == id }) ?? nil)
                }
                let favoritesResult = favorites.compactMap { $0 }
                self.favoriteVenues = favoritesResult
                
                for type in VenueType.allCases {
                    venuesDict[type] = venuesDict[type]!.filter { !favoritesIDs.contains($0.id) }
                }
                self.diningVenues = venuesDict
                
            case .failure(let error):
                self.alertType = error
            }
            
            self.diningVenuesIsLoading = false
        }
    }

    func refreshMenus(cache: Bool?, at date: Date = Date()) async {
        let lastRequest = UserDefaults.standard.getLastCachedMenuRequest()
        if diningMenus.isEmpty || !Calendar.current.isDate(date, inSameDayAs: Date()) || (lastRequest == nil || !lastRequest!.isToday) {
            let result = await DiningAPI.instance.fetchDiningMenus(at: date)
            switch result {
            case .success(let response):
                withAnimation {
                    for id in DiningVenue.menuUrlDict.keys {
                        self.diningMenus[id] = MenuList(menus: [])
                    }
                    for venueMenus in response {
                        self.diningMenus[venueMenus.menus[0].venueInfo.id] = venueMenus
                    }
                }
                if cache != nil && cache! {
                    DiningAPI.instance.saveAllMenusToCache(menus: self.diningMenus)
                    UserDefaults.standard.setLastCachedMenuRequest(date)
                }
            case .failure(let error):
                self.alertType = error
            }
        } else {
            // getting menus from cache
            Task { @MainActor in self.diningMenus = DiningAPI.instance.getMenus() }
        }
    }

    func refreshBalance() async {
        guard let diningToken = KeychainAccessible.instance.getDiningToken() else {
            UserDefaults.standard.clearDiningBalance()
            Task { @MainActor in self.diningBalance = DiningBalance(date: Date.dayOfMonthFormatter.string(from: Date()), diningDollars: "0.0", regularVisits: 0, guestVisits: 0, addOnVisits: 0) }
            return
        }
        let result = await DiningAPI.instance.getDiningBalance(diningToken: diningToken)
        switch result {
        case .success(let balance):
            try? Storage.storeThrowing(balance, to: .groupCaches, as: DiningBalance.directory)
            self.diningBalance = balance
        case .failure:
            return
        }
    }
    
    func addVenueToFavorites(venue: DiningVenue) {
        withAnimation {
            self.favoriteVenues.append(venue)
            self.diningVenues[venue.venueType]?.removeAll { $0.id == venue.id }
        }
        UserDefaults(suiteName: Storage.appGroupID)?.set(self.favoriteVenues.map(\.id), forKey: "diningFavorites")
        UserDBManager.shared.saveDiningPreference(for: self.favoriteVenues.map(\.id) + [venue.id])
    }
    
    func removeVenueFromFavorites(venue: DiningVenue) {
        if let index = self.favoriteVenues.firstIndex(where: { $0.id == venue.id }) {
            self.favoriteVenues.remove(at: index)
            self.diningVenues[venue.venueType] = [venue] + self.diningVenues[venue.venueType]!
            UserDefaults(suiteName: Storage.appGroupID)?.set(self.favoriteVenues.map(\.id), forKey: "diningFavorites")
            UserDBManager.shared.saveDiningPreference(for: self.favoriteVenues.map(\.id))
        }
    }
    
    func removeVenuesFromFavorites(indexSet: IndexSet) {
        if let index = indexSet.first {
            let venue = self.favoriteVenues[index]
            withAnimation {
                self.favoriteVenues.remove(atOffsets: indexSet)
                self.diningVenues[venue.venueType] = [venue] + self.diningVenues[venue.venueType]!
            }
            UserDefaults(suiteName: Storage.appGroupID)?.set(self.favoriteVenues.map(\.id), forKey: "diningFavorites")
            UserDBManager.shared.saveDiningPreference(for: self.favoriteVenues.map(\.id))
        }
    }
    
    func moveFavorite(fromOffsets source: IndexSet, toOffset destination: Int) {
        self.favoriteVenues.move(fromOffsets: source, toOffset: destination)
        UserDefaults(suiteName: Storage.appGroupID)?.set(self.favoriteVenues.map(\.id), forKey: "diningFavorites")
        UserDBManager.shared.saveDiningPreference(for: self.favoriteVenues.map(\.id))
    }
}
