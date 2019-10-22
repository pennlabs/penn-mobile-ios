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
            let testResponse = try! JSONDecoder().decode(DiningAPIResponse.self, from: data)
            if let diningAPIResponse = try? JSONDecoder().decode(DiningAPIResponse.self, from: data) {
                DiningDataStore.shared.store(response: diningAPIResponse)
                completion(true, false)
            } else {
                completion(false, true)
            }
            //let success = DiningHoursData.shared.loadHoursForAllVenues(for: json)
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

// MARK: - Dining API
extension DiningAPI {
    func fetchDiningBalance(_ completion: @escaping (_ diningBalance: DiningBalance?) -> Void) {
        getRequest(url: diningBalanceUrl) { (dictionary, error, statusCode) in
            
            if statusCode != 200 || dictionary == nil {
                completion(nil)
                return
            }
            
            let json = JSON(dictionary!)
            let balance = json["balance"]
            if let diningDollars = balance["dining_dollars"].float,
                let swipes = balance["swipes"].int,
                let guestSwipes = balance["guest_swipes"].int,
                let timestamp = balance["timestamp"].string {
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                if let lastUpdated = formatter.date(from: timestamp){
                    completion(DiningBalance(diningDollars: diningDollars, visits: swipes, guestVisits: guestSwipes, lastUpdated: lastUpdated))
                    return
                }
            }
            completion(nil)
        }
    }
}

/*
extension DiningHoursData {
    fileprivate func loadHoursForAllVenues(for json: JSON) -> Bool {
        guard let jsonArray = json["document"]["venue"].array else {
            return false
        }
        
        for json in jsonArray {
            //loadHoursForSingleVenue(for: json)
            
            let venueName = DiningVenueName.getVenueName(for: json["name"].stringValue)
            let _ = loadWeeklyHoursForSingleVenue(with: json, for: venueName)
        }
        
        if !Storage.fileExists(DiningVenue.directory, in: .caches) {
            let mapping = getIdMapping(jsonArray: jsonArray)
            Storage.store(mapping, to: .caches, as: DiningVenue.directory)
        }
        return true
    }
    
    fileprivate func loadWeeklyHoursForSingleVenue(with json: JSON, for venue: DiningVenueName) -> Bool {
        let decoder = JSONDecoder()
        do {
            let decodedHours = try decoder.decode(DiningVenueForWeek.self, from: json.rawData())
            processDecodedHours(hours: decodedHours, for: venue)
        } catch {
            print(error)
            return false
        }
        return true
    }
}
*/
