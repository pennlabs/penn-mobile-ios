//
//  DiningAPI.swift
//  PennMobile
//
//  Created by Josh Doman on 8/5/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import SwiftyJSON
import Foundation

public final class DiningAPI: Sendable {
    public static let defaultVenueIds: [Int] = [593, 636, 1442, 639]

    public static let instance = DiningAPI()

    let diningUrl = "https://pennmobile.org/api/dining/venues/"
    let diningMenuUrl = "https://pennmobile.org/api/dining/menus/"
    
    public static let favoritesCacheFileName = "diningFavoritesCache"

    let diningInsightsUrl = "https://pennmobile.org/api/dining/"

    public func fetchDiningHours() async -> Result<[DiningVenue], NetworkingError> {
        guard let (data, _) = try? await URLSession.shared.data(from: URL(string: diningUrl)!) else {
            return .failure(.serverError)
        }
        
        
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        if let diningVenues = try? decoder.decode([DiningVenue].self, from: data) {
            self.saveToCache(diningVenues)
            return .success(diningVenues)
        } else {
            return .failure(.parsingError)
        }
    }

    public func fetchDiningMenus(at date: Date = Date()) async -> Result<[MenuList], NetworkingError> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: date)
        guard let (data, _) = try? await URLSession.shared.data(from: URL(string: diningMenuUrl + dateStr + "/")!) else {
            return .failure(.serverError)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        if let diningMenus = try? decoder.decode([DiningMenu].self, from: data) {
            let menus: [Int: [DiningMenu]] = Dictionary(grouping: diningMenus, by: { $0.venueInfo.id })
            let result = menus.values.map { MenuList(menus: $0) }
            return .success(result)
        } else {
            return .failure(.parsingError)
        }
    }
}

// Dining Data Storage
public extension DiningAPI {
    // MARK: - Get Methods
    func getVenues() -> [DiningVenue] {
        return Storage.retrieveDiscardingInvalid(DiningVenue.directory, from: .groupCaches, as: [DiningVenue].self) ?? []
    }

    /// The venue IDs the user has favorited, as last cached. Empty if nothing is cached yet.
    func getFavoriteVenueIds() -> [Int] {
        return Storage.retrieveDiscardingInvalid(DiningVenue.favoritesDirectory, from: .caches, as: [Int].self) ?? []
    }

    func getSectionedVenues() -> [VenueType: [DiningVenue]] {
        var venuesDict = [VenueType: [DiningVenue]]()
        for type in VenueType.allCases {
            venuesDict[type] = getVenues().filter({ $0.venueType == type })
        }
        return venuesDict
    }
    
    func getSectionedVenuesAndFavorites() -> ([VenueType: [DiningVenue]], [DiningVenue]) {
        return splitFavorites(out: getSectionedVenues(), favoriteIds: getFavoriteVenueIds())
    }

    /// Pulls the favorited venues out of the sectioned venues, in the order the IDs were given.
    func splitFavorites(out sectionedVenues: [VenueType: [DiningVenue]], favoriteIds: [Int]) -> ([VenueType: [DiningVenue]], [DiningVenue]) {
        var sectionedVenues = sectionedVenues
        let favorites = favoriteIds.compactMap { id in
            sectionedVenues[.dining]?.first(where: { $0.id == id }) ?? sectionedVenues[.retail]?.first(where: { $0.id == id })
        }

        for type in VenueType.allCases {
            sectionedVenues[type] = sectionedVenues[type]?.filter { !favoriteIds.contains($0.id) }
        }

        return (sectionedVenues, favorites)
    }

    func getVenues<T: Collection>(with ids: T) -> [DiningVenue] where T.Element == Int {
        return getVenues().filter({ ids.contains($0.id) })
    }
    
    func getMenus() -> [Int: MenuList] {
        return Storage.retrieveDiscardingInvalid(MenuList.directory, from: .caches, as: [Int: MenuList].self) ?? [:]
    }

    // MARK: - Cache Methods
    func saveToCache(_ venues: [DiningVenue]) {
        Storage.store(venues, to: .groupCaches, as: DiningVenue.directory)
    }

    func saveMenuToCache(id: Int, _ menu: MenuList) {
        var menus = getMenus()
        menus[id] = menu
        Storage.store(menus, to: .caches, as: MenuList.directory)
    }
    
    func saveAllMenusToCache(menus: [Int: MenuList]) {
        for (id, menu) in menus {
            self.saveMenuToCache(id: id, menu)
        }
    }
}

// MARK: Dining Balance
extension DiningAPI {
    public func getDiningBalance(diningToken: String) async -> Result<DiningBalance, NetworkingError> {
        let url = URL(string: "https://prod.campusexpress.upenn.edu/api/v1/dining/currentBalance")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(diningToken, forHTTPHeaderField: "x-authorization")
        guard let (data, response) = try? await URLSession.shared.data(for: request), let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            return .failure(.serverError)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        if let balance = try? decoder.decode(DiningBalance.self, from: data) {
            return .success(balance)
        } else {
            return .failure(.parsingError)
        }
    }
}

// MARK: Past Dining Balances
extension DiningAPI {
    func getPastDiningBalances(diningToken: String, startDate: String) async -> Result<[DiningBalance], NetworkingError> {
        var url = URL(string: "https://prod.campusexpress.upenn.edu/api/v1/dining/pastBalances")!
        let formatter = Date.dayOfMonthFormatter
        let endDate = formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date().localTime)!)
        url.appendQueryItem(name: "start_date", value: startDate)
        url.appendQueryItem(name: "end_date", value: endDate)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(diningToken, forHTTPHeaderField: "x-authorization")
        guard let (data, response) = try? await URLSession.shared.data(for: request), let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            return .failure(.serverError)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        if let decodedBalances = try? decoder.decode(PastDiningBalances.self, from: data) {
            return .success(decodedBalances.balanceList)
        } else {
            return .failure(.parsingError)
        }
    }
}

// MARK: Current Dining Plan Start Date
extension DiningAPI {
    func getDiningPlanStartDate(diningToken: String) async -> Result<Date, NetworkingError> {
        let url = URL(string: "https://prod.campusexpress.upenn.edu/api/v1/dining/currentPlan")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(diningToken, forHTTPHeaderField: "x-authorization")
        guard let (data, response) = try? await URLSession.shared.data(for: request), let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            return .failure(.serverError)
        }
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        guard let plan = try? decoder.decode(DiningPlan.self, from: data) else {
            return .failure(.parsingError)
        }
        guard plan.name != "No Plan" else {
            return .failure(.other)
        }
        
        return .success(plan.start_date)
    }
}
