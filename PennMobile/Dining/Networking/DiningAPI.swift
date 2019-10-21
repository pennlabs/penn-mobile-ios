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
        getRequest(url: diningUrl) { (dictionary, error, statusCode) in
            
            if statusCode == nil {
                completion(false, false)
                return
            }
            
            if statusCode != 200 {
                completion(false, true)
                return
            }
            
            if dictionary == nil {
                completion(false, true)
                return
            }
            
            let json = JSON(dictionary!)
            let success = DiningHoursData.shared.loadHoursForAllVenues(for: json)
            completion(success, false)
        }
    }
    
    func fetchDetailPageHTML(for venue: DiningVenueName, _ completion: @escaping (_ html: String?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let urlString = DiningDetailModel.getUrl(for: venue),
                let url = URL(string: urlString) else {
                return
            }
            
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
    
    fileprivate func processDecodedHours(hours: DiningVenueForWeek, for venue: DiningVenueName) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd:HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "EST")
        
        if let dateHours = hours.dateHours {
            for eachDayIndex in dateHours.indices {
                let eachDay = dateHours[eachDayIndex]
                
                var hoursForDay = [OpenClose]()
                
                let dateString = eachDay.date
                var closedFlag = false
                var closedTime: OpenClose?
                
                for eachMeal in eachDay.meal {
                    let openString = dateString + ":" + eachMeal.open
                    let closeString = dateString + ":" + eachMeal.close
                    
                    guard let openDate = formatter.date(from: openString)?.adjustedFor11_59,
                        let closeDate = formatter.date(from: closeString)?.adjustedFor11_59 else { continue }
                    
                    let openClose = OpenClose(open: openDate, close: closeDate, meal: eachMeal.meal)
                    if eachMeal.meal == "Closed" {
                        closedFlag = true
                        closedTime = openClose
                    } else if !hoursForDay.containsOverlappingTime(with: openClose) {
                        hoursForDay.append(openClose)
                    }
                }
                if let closedTime = closedTime, closedFlag {
                    hoursForDay = hoursForDay.filter { !$0.overlaps(with: closedTime) }
                }
                
                self.load(hours: hoursForDay, on: eachDay.date, for: venue)
            }
        }
    }
    
    fileprivate func getIdMapping(jsonArray: [JSON]) -> [Int: String] {
        var mapping = [Int: String]()
        for json in jsonArray {
            let name = json["name"].stringValue
            let id = json["id"].intValue
            mapping[id] = name
        }
        return mapping
    }
}
