//
//  DiningAPI.swift
//  PennMobile
//
//  Created by Josh Doman on 8/5/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import SwiftyJSON
import Foundation

class DiningAPI {

    static let instance = DiningAPI()

    let diningUrl = "https://pennmobile.org/api/dining/venues/"
    let diningMenuUrl = "https://pennmobile.org/api/dining/menus/"

    let diningInsightsUrl = "https://pennmobile.org/api/dining/"

    func fetchDiningHours() async -> Result<[DiningVenue], NetworkingError> {
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

    func fetchDiningMenus(at date: Date = Date()) async -> Result<[MenuList], NetworkingError> {
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
extension DiningAPI {
    // MARK: - Get Methods
    func getVenues() -> [DiningVenue] {
        if Storage.fileExists(DiningVenue.directory, in: .caches) {
            return Storage.retrieve(DiningVenue.directory, from: .caches, as: [DiningVenue].self)
        } else {
            return []
        }
    }

    func getSectionedVenues() -> [VenueType: [DiningVenue]] {
        var venuesDict = [VenueType: [DiningVenue]]()
        for type in VenueType.allCases {
            venuesDict[type] = getVenues().filter({ $0.venueType == type })
        }
        return venuesDict
    }
    
    func getSectionedVenuesAndFavorites() -> ([VenueType: [DiningVenue]], [DiningVenue]) {
        var sectionedVenues = getSectionedVenues()
        if Storage.fileExists(DiningVenue.favoritesDirectory, in: .caches) {
            let favoritesIDs = Storage.retrieve(DiningVenue.favoritesDirectory, from: .caches, as: [Int].self)
            var favorites: [DiningVenue?] = []
            for id in favoritesIDs {
                favorites.append(sectionedVenues[.dining]?.first(where: { $0.id == id }) ?? sectionedVenues[.retail]?.first(where: { $0.id == id }) ?? nil)
            }
            let favoritesResult = favorites.compactMap { $0 }
            
            for type in VenueType.allCases {
                sectionedVenues[type] = sectionedVenues[type]!.filter { !favoritesIDs.contains($0.id) }
            }
            
            return (sectionedVenues, favoritesResult)
        } else {
            Storage.store(Array<Int>(), to: .caches, as: DiningVenue.favoritesDirectory)
            return (sectionedVenues, [])
        }
    }

    func getVenues<T: Collection>(with ids: T) -> [DiningVenue] where T.Element == Int {
        return getVenues().filter({ ids.contains($0.id) })
    }
    
    func getMenus() -> [Int: MenuList] {
        if Storage.fileExists(MenuList.directory, in: .caches) {
            return Storage.retrieve(MenuList.directory, from: .caches, as: [Int: MenuList].self)
        } else {
            return [:]
        }
    }

    // MARK: - Cache Methods
    func saveToCache(_ venues: [DiningVenue]) {
        Storage.store(venues, to: .caches, as: DiningVenue.directory)
    }

    func saveMenuToCache(id: Int, _ menu: MenuList) {
        if Storage.fileExists(MenuList.directory, in: .caches) {
            var menus = Storage.retrieve(MenuList.directory, from: .caches, as: [Int: MenuList].self)

            menus[id] = menu

            Storage.store(menus, to: .caches, as: MenuList.directory)
        } else {
            Storage.store([id: menu], to: .caches, as: MenuList.directory)
        }
    }
    
    func saveAllMenusToCache(menus: [Int: MenuList]) {
        for (id, menu) in menus {
            self.saveMenuToCache(id: id, menu)
        }
    }
}

// MARK: Dining Balance
extension DiningAPI {
    func getDiningBalance(diningToken: String) async -> Result<DiningBalance, NetworkingError> {
        let url = URL(string: "https://prod.campusexpress.upenn.edu/api/v1/dining/currentBalance")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(diningToken, forHTTPHeaderField: "x-authorization")
        guard let (data, response) = try? await URLSession.shared.data(for: request), let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
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
        guard let (data, response) = try? await URLSession.shared.data(for: request), let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
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
        guard let (data, response) = try? await URLSession.shared.data(for: request), let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return .failure(.serverError)
        }
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        if let plan = try? decoder.decode(DiningPlan.self, from: data) {
            return .success(plan.start_date)
        } else {
            return .failure(.parsingError)
        }
    }
}
