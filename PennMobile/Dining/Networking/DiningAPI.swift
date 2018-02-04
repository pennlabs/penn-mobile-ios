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

class DiningAPI: Requestable {
    
    static let instance = DiningAPI()
    
    let diningUrl = "https://api.pennlabs.org/dining/venues"
    
    func fetchDiningHours(_ completion: @escaping (_ success: Bool) -> Void) {
        getRequest(url: diningUrl) { (dictionary) in
            if dictionary == nil {
                completion(false)
                return
            }
            
            let json = JSON(dictionary!)
            let success = DiningHoursData.shared.loadHoursForAllVenues(for: json)
            completion(success)
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

extension DiningHoursData {
    fileprivate func loadHoursForAllVenues(for json: JSON) -> Bool {
        guard let jsonArray = json["document"]["venue"].array else {
            return false
        }
        
        for json in jsonArray {
            loadHoursForSingleVenue(for: json)
        }
        
        return true
    }
    
    fileprivate func loadHoursForSingleVenue(for json: JSON) {
        let name = json["name"].stringValue
        let venueName = DiningVenueName.getVenueName(for: name)
        if venueName == .unknown {
            return
        }

        let today = DateFormatter.yyyyMMdd.string(from: Date())
        let todayJSON = json["dateHours"].array?.filter { json -> Bool in
            return json["date"].string == today
            }.first
        
        var hours = [OpenClose]()
        
        // Not open today
        if todayJSON == nil {
            self.load(hours: [], for: venueName)
        }
        
        guard let json = todayJSON, let timesJSON = json["meal"].array else {
            return
        }
        
        for json in timesJSON {
            guard let type = json["type"].string, type == "Lunch" || type == "Brunch" || type == "Dinner" || type == "Breakfast" || type == "Late Night" || name.range(of: type) != nil, let open = json["open"].string, let close = json["close"].string else { return }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            formatter.timeZone = TimeZone(abbreviation: "EST")
            
            guard let openDate = formatter.date(from: open)?.adjustedFor11_59, let closeDate = formatter.date(from: close)?.adjustedFor11_59 else { return }
            
            let time = OpenClose(open: openDate, close: closeDate)
            if !hours.containsOverlappingTime(with: time) {
                hours.append(time)
            }
        }
        
        self.load(hours: hours, for: venueName)
    }
}

