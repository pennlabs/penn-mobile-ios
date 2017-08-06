//
//  DiningAPI.swift
//  PennMobile
//
//  Created by Josh Doman on 8/5/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import PromiseKit
import SwiftyJSON
import Foundation

class DiningAPI {
    
    static func getVenueHours(for venues: [String]) -> Promise<Dictionary<String, DiningVenue>> {
        return Promise { fullfill, reject in
            let urlString = "https://api.pennlabs.org/dining/venues"
            let url = URL(string: urlString)!
            let request = URLRequest(url: url)
            let session = URLSession.shared
            
            let dataPromise: URLDataPromise = session.dataTask(with: request)
            _ = dataPromise.then { data -> Void in
                let json = JSON(data)
                let result = try Dictionary<String, DiningVenue>(json: json, venues: venues)
                fullfill(result)
                }.catch(execute: reject)
        }
    }
    
}

extension Dictionary where Key == String, Value == DiningVenue {
    init(json: JSON, venues: [String]) throws {
        guard let jsonArray = json["document"]["venue"].array else {
            throw JSONError.unexpectedRootNode("Document/Venues missing in JSON")
        }
        self.init()
        for json in jsonArray {
            let venue = try DiningVenue(json: json)
            
            //filter for provided venues/use venue names
            for otherVenue in venues {
                if otherVenue.range(of: venue.name) != nil || venue.name.range(of: otherVenue) != nil {
                    venue.name = otherVenue
                    self[venue.name] = venue
                }
            }
        }
    }
}

extension DiningVenue {
    convenience init(json: JSON) throws {
        guard let name = json["name"].string else {
            throw JSONError.unexpectedRootNode("Dining Name missing in JSON")
        }
        self.init(name: name)
        
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        let todayJSON = json["dateHours"].array?.filter { json -> Bool in
            return json["date"].string == today
            }.first
        
        self.times = [OpenClose]()
        
        guard let json = todayJSON, let timesJSON = json["meal"].array else {
            return
        }
        
        for json in timesJSON {
            if let type = json["type"].string, type == "Lunch" || type == "Brunch" || type == "Dinner" || type == "Breakfast" || type == "Late Night" || name.range(of: type) != nil, let open = json["open"].string, let close = json["close"].string {
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                formatter.timeZone = TimeZone(abbreviation: "EST")
                
                if let openDate = formatter.date(from: open)?.adjustedFor11_59, let closeDate = formatter.date(from: close)?.adjustedFor11_59 {
                    
                    let time = OpenClose(open: openDate, close: closeDate)
                    if let tempTimes = self.times, !tempTimes.contains(time) { //remove duplicate times
                        self.times?.append(time)
                    }
                }
            }
        }
    }
}

