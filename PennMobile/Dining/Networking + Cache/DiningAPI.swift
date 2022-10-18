//
//  DiningAPI.swift
//  PennMobile
//
//  Created by Josh Doman on 8/5/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import SwiftyJSON
import Foundation

class DiningAPI: Requestable {

    static let instance = DiningAPI()

    let diningUrl = "https://pennmobile.org/api/dining/venues/"
    let diningMenuUrl = "https://pennmobile.org/api/dining/daily_menu/"
    // TODO: Broken API, need to fetch locally

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

    func fetchDiningMenu(for id: Int, at date: Date = Date(), _ completion: @escaping (_ result: Result<DiningMenuAPIResponse, NetworkingError>) -> Void) {
        return completion(.failure(.parsingError))
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

    func getVenues<T: Collection>(with ids: T) -> [DiningVenue] where T.Element == Int {
        return getVenues().filter({ ids.contains($0.id) })
    }

    func getMenus() -> [Int: DiningMenuAPIResponse] {
        if Storage.fileExists(DiningMenuAPIResponse.directory, in: .caches) {
            return Storage.retrieve(DiningMenuAPIResponse.directory, from: .caches, as: [Int: DiningMenuAPIResponse].self)
        } else {
            return [:]
        }
    }

    // MARK: - Cache Methods
    func saveToCache(_ venues: [DiningVenue]) {
        Storage.store(venues, to: .caches, as: DiningVenue.directory)
    }

    func saveToCache(id: Int, _ menu: DiningMenuAPIResponse) {
        if Storage.fileExists(DiningMenuAPIResponse.directory, in: .caches) {
            var menus = Storage.retrieve(DiningMenuAPIResponse.directory, from: .caches, as: [Int: DiningMenuAPIResponse].self)

            menus[id] = menu

            Storage.store(menus, to: .caches, as: DiningMenuAPIResponse.directory)
        } else {
            Storage.store([id: menu], to: .caches, as: DiningMenuAPIResponse.directory)
        }
    }
}

// MARK: Dining Balance
extension DiningAPI {
    func getDiningBalance(diningToken: String, _ callback: @escaping (_ balance: DiningBalance?) -> Void) {
        let url = URL(string: "https://prod.campusexpress.upenn.edu/api/v1/dining/currentBalance")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(diningToken, forHTTPHeaderField: "x-authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, _ ) in
            if let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let balance = try? decoder.decode(DiningBalance.self, from: data)
                callback(balance)
                return
            }
            callback(nil)
        }
        task.resume()
    }
}

// MARK: Past Dining Balances
extension DiningAPI {
    func getPastDiningBalances(diningToken: String, startDate: String, _ callback: @escaping (_ balances: [DiningBalance]?) -> Void) {
        var url = URL(string: "https://prod.campusexpress.upenn.edu/api/v1/dining/pastBalances")!
        let formatter = Date.dayOfMonthFormatter
        let endDate = formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date().localTime)!)
        url.appendQueryItem(name: "start_date", value: startDate)
        url.appendQueryItem(name: "end_date", value: endDate)
        UserDefaults.standard.setNextAnalyticsStartDate(formatter.string(from: Date()))
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(diningToken, forHTTPHeaderField: "x-authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, _ ) in
            if let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let balance = try? decoder.decode(PastDiningBalances.self, from: data)
                callback(balance?.balanceList)
                return
            }
            callback(nil)
        }
        task.resume()
    }
}

// MARK: Current Dining Plan Start Date
extension DiningAPI {
    func getDiningPlanStartDate(diningToken: String, _ callback: @escaping (_ startDate: Date?) -> Void) {
        let url = URL(string: "https://prod.campusexpress.upenn.edu/api/v1/dining/currentPlan")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(diningToken, forHTTPHeaderField: "x-authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, _ ) in
            if let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                let plan = try? decoder.decode(DiningPlan.self, from: data)
                callback(plan?.start_date)
                return
            }
            callback(nil)
        }
        task.resume()
    }
}
