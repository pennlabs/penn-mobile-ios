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
    @Published var diningMenus = DiningAPI.instance.getMenus()

    @Published var diningVenuesIsLoading = false
    @Published var alertType: NetworkingError?

    @Published var diningBalance = UserDefaults.standard.getDiningBalance() ?? DiningBalance(date: Date.dayOfMonthFormatter.string(from: Date()), diningDollars: "0.0", regularVisits: 0, guestVisits: 0, addOnVisits: 0)
    // MARK: - Venue Methods
    let ordering: [VenueType] = [.dining, .retail]

    func refreshVenues() async {
        let lastRequest = UserDefaults.standard.getLastDiningHoursRequest()
        // Sometimes when building the app, dining venue list is empty, but because it has refreshed within the day, it does not refresh again. Now, refreshes if the list of venues is completely empty
        if lastRequest == nil || !lastRequest!.isToday || diningVenues.isEmpty {
            self.diningVenuesIsLoading = true
            let result = await DiningAPI.instance.fetchDiningHours()
            switch result {
            case .success(let diningVenues):
                UserDefaults.standard.setLastDiningHoursRequest()
                var venuesDict = [VenueType: [DiningVenue]]()
                for type in VenueType.allCases {
                    venuesDict[type] = diningVenues.filter({ $0.venueType == type })
                }
                self.diningVenues = venuesDict
            case .failure(let error):
                self.alertType = error
            }

            self.diningVenuesIsLoading = false
        }
    }

    func refreshMenu(for id: Int, at date: Date = Date()) {
        let lastRequest = UserDefaults.standard.getLastMenuRequest(id: id)
        if  Calendar.current.isDate(date, inSameDayAs: Date()) && (lastRequest == nil || !lastRequest!.isToday) {
            DiningAPI.instance.fetchDiningMenu(for: id) { result in
                switch result {
                case .success(let diningMenu):
                    withAnimation {
                        self.diningMenus[id] = diningMenu
                    }
                case .failure(let error):
                    self.alertType = error
                }
            }
        } else {
            DiningAPI.instance.fetchDiningMenu(for: id, at: date) { result in
                switch result {
                case .success(let diningMenu):
                    withAnimation {
                        self.diningMenus[id] = diningMenu
                    }
                case .failure(let error):
                    self.alertType = error
                }
            }
        }
    }

    func refreshBalance() async {
        guard let diningToken = KeychainAccessible.instance.getDiningToken() else {
            UserDefaults.standard.clearDiningBalance()
            self.diningBalance = DiningBalance(date: Date.dayOfMonthFormatter.string(from: Date()), diningDollars: "0.0", regularVisits: 0, guestVisits: 0, addOnVisits: 0)
            return
        }
        let result = await DiningAPI.instance.getDiningBalance(diningToken: diningToken)
        switch result {
        case .success(let balance):
            UserDefaults.standard.setdiningBalance(balance)
            self.diningBalance = balance
        case .failure:
            return
        }
    }
}
