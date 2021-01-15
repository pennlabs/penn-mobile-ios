//
//  DiningViewModelSwiftUI.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 4/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 14, *)
class DiningViewModelSwiftUI: ObservableObject {
    
    static let instance = DiningViewModelSwiftUI()
    
    @Published var diningVenues: [DiningVenue.VenueType : [DiningVenue]] = DiningAPI.instance.getSectionedVenues()
    @Published var diningInsights = DiningAPI.instance.getInsights()
    
    @Published var diningVenuesIsLoading = false
    @Published var diningInsightsIsLoading = false
    
    @Published var presentAlert = false
    @Published var alertType: NetworkingError = .other
    
    // MARK:- Venue Methods
    let ordering: [DiningVenue.VenueType] = [.dining, .retail]
    
    func refreshVenues() {
        diningVenuesIsLoading = true
        print("ERROR")
        DiningAPI.instance.fetchDiningHours { (result) in
            print(result)
            switch result {
            case .success(let diningVenues):
                DispatchQueue.main.async {
                    var venuesDict = [DiningVenue.VenueType : [DiningVenue]]()
                    for type in DiningVenue.VenueType.allCases {
                        venuesDict[type] = diningVenues.document.venues.filter({ $0.venueType == type })
                    }
                    self.diningVenues = venuesDict
                }
            case .failure(.noInternet):
                DispatchQueue.main.async {
                    self.presentAlert = true
                    self.alertType = .noInternet
                    self.diningVenuesIsLoading = false
                }
            case .failure(.authenticationError):
                DispatchQueue.main.async {
                    self.presentAlert = true
                    self.alertType = .authenticationError
                    self.diningVenuesIsLoading = false
                }
            default:
                // Need to figure out what to do
                DispatchQueue.main.async {
                    self.presentAlert = true
                    self.alertType = .other
                    self.diningVenuesIsLoading = true
                }
            }
        }
    }
    
    func getType(forSection section: Int) -> DiningVenue.VenueType {
        return ordering[section]
    }
    
    func getVenues(forSection section: Int) -> [DiningVenue] {
        let venueType = getType(forSection: section)
        return diningVenues[venueType] ?? []
    }
    
    func getVenue(for indexPath: IndexPath) -> DiningVenue {
        return getVenues(forSection: indexPath.section)[indexPath.row]
    }
    
    func getHeaderTitle(type: DiningVenue.VenueType) -> String {
        switch type {
        case .dining:
            return "Halls"
        case .retail:
            return "Retail"
        case .unknown:
            return "Unknown"
        }
    }
    
    // MARK: - Insights
    
    func refreshInsights() {
        self.diningInsightsIsLoading = true
        
        DiningAPI.instance.fetchDiningInsights { (result) in
            DispatchQueue.main.async {
                self.diningInsightsIsLoading = false
                
                switch result {
                case .success(let diningInsights):
                    self.diningInsights = diningInsights
                default:
                    self.presentAlert = true
                    self.diningInsights = nil
                }
            }
        }
    }
}
