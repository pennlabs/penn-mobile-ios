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

    func fetchDiningHours(_ completion: @escaping (_ success: Bool, _ error: Bool) -> Void) {
        
        getRequestData(url: diningUrl) { (data, error, statusCode) in
            if statusCode == nil {
                completion(false, false)
                return
            }
            
            if statusCode != 200 {
                completion(false, true)
                return
            }
            
            guard let data = data else { completion(false, true); return }
            
            if let diningAPIResponse = try? JSONDecoder().decode(DiningAPIResponse.self, from: data) {
                DiningDataStore.shared.store(response: diningAPIResponse)
                completion(true, false)
            } else {
                completion(false, true)
            }
        }
    }
    
    func fetchDiningStatistics(_ completion: @escaping (_ success: Bool, _ error: Bool) -> Void) {
        // still update the data store inside here, but also return the data through the closure
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
