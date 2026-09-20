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
    var presentToast: ToastPresentationCallback?

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
        self.diningVenuesIsLoading = true
        defer { self.diningVenuesIsLoading = false }

        let diningResult = await DiningAPI.instance.fetchDiningHours()
        guard case .success(let diningVenues) = diningResult else {
            if case .failure(let error) = diningResult {
                self.alertType = error
            }
            return
        }
        
        
        var favorites: [Int] = []
        if case .success(let networkFavorites) = await UserDBManager.shared.fetchDiningPreferences() {
            favorites = networkFavorites.map(\.id)
            Storage.store(favorites, to: .caches, as: DiningVenue.favoritesDirectory)
        } else if let cached = try? Storage.retrieveThrowing(DiningVenue.favoritesDirectory, from: .caches, as: [Int].self) {
            favorites = cached
        } else {
            presentToast?(.init(message: "Failed to load dining halls due to network issues."))
        }
        
        var venuesDict = [VenueType: [DiningVenue]]()
        for type in VenueType.allCases {
            venuesDict[type] = diningVenues.filter { $0.venueType == type && !favorites.contains($0.id) }
        }
        
        self.favoriteVenues = favorites.compactMap { id in diningVenues.first { $0.id == id } }
        self.diningVenues = venuesDict
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
