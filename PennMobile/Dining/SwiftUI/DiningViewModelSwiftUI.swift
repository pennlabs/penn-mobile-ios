//
//  DiningViewModelSwiftUI.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 4/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

@available(iOS 14, *)
class DiningViewModelSwiftUI: ObservableObject {
    static let instance = DiningViewModelSwiftUI()
    
    @Published var diningVenues: [DiningVenue.VenueType : [DiningVenue]] = DiningAPI.instance.getSectionedVenues()
    @Published var diningInsights = DiningAPI.instance.getInsights()
    @Published var diningMenus = DiningAPI.instance.getMenus()
    
    @Published var diningVenuesIsLoading = false
    @Published var diningInsightsIsLoading = false
    
    @Published var alertType: NetworkingError? = nil
    
    @Published var swipes = 0
    @Published var diningDollars = 0.0
    
    // MARK:- Venue Methods
    let ordering: [DiningVenue.VenueType] = [.dining, .retail]
    
    init() {
        refreshVenues()
        refreshBalance()
    }
    
    func refreshVenues() {
        let lastRequest = UserDefaults.standard.getLastDiningHoursRequest()
        
        if lastRequest == nil || !lastRequest!.isToday {
            self.diningVenuesIsLoading = true
            
            DiningAPI.instance.fetchDiningHours { result in
                self.diningVenuesIsLoading = false
                
                switch result {
                case .success(let diningVenues):
                    UserDefaults.standard.setLastDiningHoursRequest()
                    var venuesDict = [DiningVenue.VenueType : [DiningVenue]]()
                    for type in DiningVenue.VenueType.allCases {
                        venuesDict[type] = diningVenues.document.venues.filter({ $0.venueType == type })
                    }
                    self.diningVenues = venuesDict
                case .failure(let error):
                    self.alertType = error
                    self.diningVenuesIsLoading = false
                }
            }
        }
    }
    
    func refreshMenu(for id: Int) {
        let lastRequest = UserDefaults.standard.getLastMenuRequest(id: id)
        if lastRequest == nil || !lastRequest!.isToday {
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
        }
    }
    
    func refreshBalance() {
        if (UserDefaults.standard.hasDiningPlan()) {
            DiningAPI.instance.fetchDiningBalance { diningBalance in
                if let diningBalance = diningBalance {
                    self.swipes = diningBalance.visits
                    self.diningDollars = Double(diningBalance.diningDollars)
                }
            }
        }
    }
    
    // MARK: - Insights
    func refreshInsights() {
        diningInsightsIsLoading = true
        
        DiningAPI.instance.fetchDiningInsights { (result) in
            self.diningInsightsIsLoading = false
            
            switch result {
            case .success(let diningInsights):
                self.diningInsights = diningInsights
            case .failure(let error):
                self.alertType = error
                self.diningInsights = nil
            }
        }
    }
}
