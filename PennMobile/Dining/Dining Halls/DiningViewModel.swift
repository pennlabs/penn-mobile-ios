//
//  DiningViewModel.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 4/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI
import PennMobileShared

@MainActor
class DiningViewModel: ObservableObject {
    static let instance = DiningViewModel()

    @Published var diningVenues: [VenueType: [DiningVenue]]
    @Published var favoriteVenues: [DiningVenue] = []
    
    @Published var diningMenus = DiningAPI.instance.getMenus()

    @Published var diningVenuesIsLoading = false
    @Published var alertType: (any Error)?

    @Published var diningBalance = (try? Storage.retrieveThrowing(DiningBalance.directory, from: .groupCaches, as: DiningBalance.self)) ?? DiningBalance(date: Date.dayOfMonthFormatter.string(from: Date()), diningDollars: "0.0", regularVisits: 0, guestVisits: 0, addOnVisits: 0)

    var areAllVenuesEmpty: Bool {
        return diningVenues.allSatisfy { _, venues in
            venues.isEmpty
        }
    }

    init() {
        let (diningVenues, favoriteVenues) = DiningAPI.instance.getSectionedVenuesAndFavorites()
        self.favoriteVenues = favoriteVenues
        self.diningVenues = diningVenues
    }
    
  // MARK: - Venue Methods
    let ordering: [VenueType] = [.dining, .retail]

    func refreshVenues() async {
        let lastRequest = UserDefaults.standard.getLastDiningHoursRequest()
        // Sometimes when building the app, dining venue list is empty, but because it has refreshed within the day, it does not refresh again. Now, refreshes if the list of venues is completely empty
        guard lastRequest == nil || !lastRequest!.isToday || areAllVenuesEmpty else { return }

        self.diningVenuesIsLoading = true
        defer { self.diningVenuesIsLoading = false }

        let venues: [DiningVenue]
        switch await DiningAPI.instance.fetchDiningHours() {
        case .success(let fetchedVenues):
            UserDefaults.standard.setLastDiningHoursRequest()
            venues = fetchedVenues
        case .failure(let error):
            // Network failed, so fall back on the cache. Only complain if that's empty too.
            venues = DiningAPI.instance.getVenues()
            if venues.isEmpty {
                self.alertType = error
            }
        }

        // Favorites must be fetched after the venues, since they're resolved against the venue cache.
        // They're also secondary: if they fail (e.g. the user is logged out), still show the venues.
        let favoriteIds: [Int]
        switch await UserDBManager.shared.fetchDiningPreferences() {
        case .success(let favorites):
            favoriteIds = favorites.map(\.id)
            Storage.store(favoriteIds, to: .caches, as: DiningVenue.favoritesDirectory)
        case .failure:
            favoriteIds = DiningAPI.instance.getFavoriteVenueIds()
        }

        var venuesDict = [VenueType: [DiningVenue]]()
        for type in VenueType.allCases {
            venuesDict[type] = venues.filter({ $0.venueType == type })
        }

        let (sectionedVenues, favoriteVenues) = DiningAPI.instance.splitFavorites(out: venuesDict, favoriteIds: favoriteIds)
        self.favoriteVenues = favoriteVenues
        self.diningVenues = sectionedVenues
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
        Storage.store(favoriteVenues.map(\.id), to: .caches, as: DiningVenue.favoritesDirectory)
        UserDBManager.shared.saveDiningPreference(for: self.favoriteVenues.map(\.id) + [venue.id])
    }
    
    func removeVenueFromFavorites(venue: DiningVenue) {
        if let index = self.favoriteVenues.firstIndex(where: { $0.id == venue.id }) {
            self.favoriteVenues.remove(at: index)
            self.diningVenues[venue.venueType] = [venue] + self.diningVenues[venue.venueType]!
            Storage.store(favoriteVenues.map(\.id), to: .caches, as: DiningVenue.favoritesDirectory)
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
            Storage.store(favoriteVenues.map(\.id), to: .caches, as: DiningVenue.favoritesDirectory)
            UserDBManager.shared.saveDiningPreference(for: self.favoriteVenues.map(\.id))
        }
    }
    
    func moveFavorite(fromOffsets source: IndexSet, toOffset destination: Int) {
        self.favoriteVenues.move(fromOffsets: source, toOffset: destination)
        Storage.store(favoriteVenues.map(\.id), to: .caches, as: DiningVenue.favoritesDirectory)
        UserDBManager.shared.saveDiningPreference(for: self.favoriteVenues.map(\.id))
    }
}
