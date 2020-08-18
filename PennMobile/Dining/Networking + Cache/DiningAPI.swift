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
    
    let diningUrl = "https://api.pennlabs.org/dining/venues"
    let diningPrefs =  "https://api.pennlabs.org/dining/preferences"
    let diningBalanceUrl = "https://api.pennlabs.org/dining/balance"
    let diningInsightsUrl = "https://studentlife.pennlabs.org/dining/"
    
    func fetchDiningHours(_ completion: @escaping (_ result: Result<DiningAPIResponse, NetworkingError>) -> Void) {
        getRequestData(url: diningUrl) { (data, error, statusCode) in
            if statusCode == nil {
                return completion(.failure(.serverError))
            }
            
            if statusCode != 200 {
                return completion(.failure(.noInternet))
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

    func fetchDiningInsights(_ completion: @escaping (_ result: Result<DiningInsightsAPIResponse, NetworkingError>) -> Void ) {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token else {
                // TODO: - Add network error handling for OAuth2
                completion(.failure(.noInternet))
                return
            }
            
            let url = URL(string: self.diningInsightsUrl)!
            var request = URLRequest(url: url, accessToken: token)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else {
                   if let error = error as? NetworkingError {
                       completion(.failure(error))
                   } else {
                       completion(.failure(.other))
                   }
                   return
                }
                
                let decoder = JSONDecoder()
                
                if let diningInsightsAPIResponse = try? decoder.decode(DiningInsightsAPIResponse.self, from: data) {
                    self.saveToCache(diningInsightsAPIResponse)
                    completion(.success(diningInsightsAPIResponse))
                } else {
                    completion(.failure(.parsingError))
                }
            }
            task.resume()
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

// MARK: - Dining Balance API
extension DiningAPI {
    func fetchDiningBalance(_ completion: @escaping (_ diningBalance: DiningBalance?) -> Void) {
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            guard let token = token else {
                completion(nil)
                return
            }
            
            let url = URL(string: self.diningBalanceUrl)!
            let request = URLRequest(url: url, accessToken: token)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 {
                    let json = JSON(data)
                    let balance = json["balance"]
                    if let diningDollars = balance["dining_dollars"].float,
                        let swipes = balance["swipes"].int,
                        let guestSwipes = balance["guest_swipes"].int,
                        let timestamp = balance["timestamp"].string {

                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        if let lastUpdated = formatter.date(from: timestamp){
                            let balance = DiningBalance(diningDollars: diningDollars, visits: swipes, guestVisits: guestSwipes, lastUpdated: lastUpdated)
                            completion(balance)
                            return
                        }
                    }
                }
                completion(nil)
            }
            task.resume()
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
    
    func getSectionedVenues() -> [DiningVenue.VenueType : [DiningVenue]] {
        var venuesDict = [DiningVenue.VenueType : [DiningVenue]]()
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
    
    func getInsights() -> DiningInsightsAPIResponse? {
        if Storage.fileExists(DiningInsightsAPIResponse.directory, in: .caches) {
            return Storage.retrieve(DiningInsightsAPIResponse.directory, from: .caches, as: DiningInsightsAPIResponse.self)
        } else {
            return nil
        }
    }
    
    // MARK: - Cache Methods
    func saveToCache(_ venues: [DiningVenue]) {
        Storage.store(venues, to: .caches, as: DiningVenue.directory)
    }
    
    func saveToCache(_ insights: DiningInsightsAPIResponse) {
        Storage.store(insights, to: .caches, as: DiningInsightsAPIResponse.directory)
    }
    
}
