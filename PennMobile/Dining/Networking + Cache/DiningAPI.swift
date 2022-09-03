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

    func fetchDiningHours(_ completion: @escaping (_ result: Result<DiningAPIResponse, NetworkingError>) -> Void) {
        getRequestData(url: diningUrl) { (data, _, statusCode) in
            if statusCode == nil {
                return completion(.failure(.noInternet))
            }

            if statusCode != 200 {
                return completion(.failure(.serverError))
            }

            guard let data = data else { return completion(.failure(.other)) }

            if let diningAPIResponse = try? JSONDecoder().decode(DiningAPIResponse.self, from: data) {
                self.saveToCache(diningAPIResponse.document.venues)
                return completion(.success(diningAPIResponse))
            } else {
                return completion(.failure(.parsingError))
            }
        }
    }

    func fetchDiningMenu(for id: Int, at date: Date = Date(), _ completion: @escaping (_ result: Result<DiningMenuAPIResponse, NetworkingError>) -> Void) {
        postRequestData(url: diningMenuUrl + "\(id)/", params: ["date": Date.dayOfMonthFormatter.string(from: date)]) { (data, _, statusCode) in
            if statusCode == nil {
                return completion(.failure(.noInternet))
            }

            if statusCode != 200 {
                return completion(.failure(.serverError))
            }

            guard let data = data else { return completion(.failure(.other)) }

            if let diningMenuAPIResponse = try? JSONDecoder().decode(DiningMenuAPIResponse.self, from: data) {
                self.saveToCache(id: id, diningMenuAPIResponse)
                return completion(.success(diningMenuAPIResponse))
            } else {
                return completion(.failure(.parsingError))
            }
        }
    }

    func fetchDetailPageHTML(for venue: DiningVenue, _ completion: @escaping (_ html: String?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let url = venue.facilityURL else { return }
            let html = try? String(contentsOf: url, encoding: .ascii)
            completion(html)
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

    func getSectionedVenues() -> [DiningVenue.VenueType: [DiningVenue]] {
        var venuesDict = [DiningVenue.VenueType: [DiningVenue]]()
        for type in DiningVenue.VenueType.allCases {
            venuesDict[type] = getVenues().filter({ $0.venueType == type })
        }
        return venuesDict
    }

    func getVenues(with ids: Set<Int>) -> [DiningVenue] {
        return getVenues().filter({ ids.contains($0.id) })
    }

    func getVenues(with ids: [Int]) -> [DiningVenue] {
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
                let balance = try? decoder.decode([DiningBalance].self, from: data)
                callback(balance)
                return
            }
            callback(nil)
        }
        task.resume()
    }
}
