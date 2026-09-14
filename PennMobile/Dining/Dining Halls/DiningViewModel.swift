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

    @Published var diningVenues: [VenueType: [DiningVenue]] = [:]
    @Published var favoriteVenues: [DiningVenue] = []

    @Published var diningMenus: [Int: MenuList] = [:]

    @Published var diningVenuesIsLoading = false
    /// Set when the venue fetch fails, so the view can offer a retry instead of showing nothing.
    @Published var venuesError: (any Error)?
    @Published var alertType: (any Error)?

    @Published var diningBalance = DiningBalance.empty

    /// Every venue from the last fetch, before being split into favorites and sections.
    private var allVenues: [DiningVenue] = []

    var areAllVenuesEmpty: Bool {
        favoriteVenues.isEmpty && diningVenues.allSatisfy { _, venues in
            venues.isEmpty
        }
    }

  // MARK: - Venue Methods
    let ordering: [VenueType] = [.dining, .retail]

    /// Splits the fetched venues into the user's favorites and the remaining sections.
    private func applyFavorites(_ favoriteIDs: [Int]) {
        favoriteVenues = DiningAPI.venues(allVenues, with: favoriteIDs)

        var venuesDict = [VenueType: [DiningVenue]]()
        for type in VenueType.allCases {
            venuesDict[type] = allVenues.filter { $0.venueType == type && !favoriteIDs.contains($0.id) }
        }
        diningVenues = venuesDict
    }

    func refreshVenues() async {
        diningVenuesIsLoading = true
        defer { diningVenuesIsLoading = false }

        switch await DiningAPI.instance.fetchDiningHours() {
        case .success(let venues):
            allVenues = venues
            venuesError = nil
            // Show the venues now, using the favorite IDs we already have. The favorites
            // request needs a login and fails often enough that waiting on it used to
            // leave the list empty.
            applyFavorites(DiningAPI.instance.favoriteVenueIDs)
        case .failure(let error):
            // Keep whatever is on screen; the view offers a retry.
            venuesError = error
            return
        }

        guard Account.isLoggedIn else { return }

        if case .success(let favoriteIDs) = await UserDBManager.shared.fetchDiningPreferences() {
            DiningAPI.instance.favoriteVenueIDs = favoriteIDs
            applyFavorites(favoriteIDs)
        }
    }

    func refreshMenus(at date: Date = Date()) async {
        switch await DiningAPI.instance.fetchDiningMenus(at: date) {
        case .success(let response):
            withAnimation {
                var menus = [Int: MenuList]()
                for id in DiningVenue.menuUrlDict.keys {
                    menus[id] = MenuList(menus: [])
                }
                for venueMenus in response {
                    guard let id = venueMenus.menus.first?.venueInfo.id else { continue }
                    menus[id] = venueMenus
                }
                self.diningMenus = menus
            }
        case .failure(let error):
            self.alertType = error
        }
    }

    func refreshBalance() async {
        guard let diningToken = KeychainAccessible.instance.getDiningToken() else {
            self.diningBalance = .empty
            return
        }

        if case .success(let balance) = await DiningAPI.instance.getDiningBalance(diningToken: diningToken) {
            self.diningBalance = balance
        }
    }

    // MARK: - Favorites
    /// Saves the favorites locally (for the widget) and on the server.
    private func saveFavorites() {
        let ids = favoriteVenues.map(\.id)
        DiningAPI.instance.favoriteVenueIDs = ids
        UserDBManager.shared.saveDiningPreference(for: ids)
    }

    func addVenueToFavorites(venue: DiningVenue) {
        withAnimation {
            self.favoriteVenues.append(venue)
            self.diningVenues[venue.venueType]?.removeAll { $0.id == venue.id }
        }
        saveFavorites()
    }

    func removeVenueFromFavorites(venue: DiningVenue) {
        if let index = self.favoriteVenues.firstIndex(where: { $0.id == venue.id }) {
            self.favoriteVenues.remove(at: index)
            self.diningVenues[venue.venueType] = [venue] + (self.diningVenues[venue.venueType] ?? [])
            saveFavorites()
        }
    }

    func removeVenuesFromFavorites(indexSet: IndexSet) {
        if let index = indexSet.first {
            let venue = self.favoriteVenues[index]
            withAnimation {
                self.favoriteVenues.remove(atOffsets: indexSet)
                self.diningVenues[venue.venueType] = [venue] + (self.diningVenues[venue.venueType] ?? [])
            }
            saveFavorites()
        }
    }

    func moveFavorite(fromOffsets source: IndexSet, toOffset destination: Int) {
        self.favoriteVenues.move(fromOffsets: source, toOffset: destination)
        saveFavorites()
    }
}
