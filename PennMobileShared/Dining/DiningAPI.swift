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

    let diningInsightsUrl = "https://pennmobile.org/api/dining/"

    public func fetchDiningHours() async -> Result<[DiningVenue], NetworkingError> {
        guard let (data, response) = try? await URLSession.shared.data(from: URL(string: diningUrl)!),
              let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            return .failure(.serverError)
        }

        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        if let diningVenues = try? decoder.decode([DiningVenue].self, from: data) {
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

// MARK: - Favorites
public extension DiningAPI {
    private static var favoritesKey: String { "diningFavoriteVenueIDs" }

    /// IDs of the user's favorite venues, in the order they chose.
    ///
    /// The server is the source of truth, but these live in the app group too: the dining
    /// hours widget can't reach the preferences endpoint, which needs an access token.
    var favoriteVenueIDs: [Int] {
        get { UserDefaults.group.array(forKey: Self.favoritesKey) as? [Int] ?? [] }
        set { UserDefaults.group.set(newValue, forKey: Self.favoritesKey) }
    }

    /// The venues matching `ids`, in the order of `ids`.
    static func venues<T: Collection>(_ venues: [DiningVenue], with ids: T) -> [DiningVenue] where T.Element == Int {
        ids.compactMap { id in venues.first { $0.id == id } }
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
