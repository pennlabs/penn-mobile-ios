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
            
            let venueName = DiningVenueName.getVenueName(for: json["name"].stringValue)
            let _ = loadWeeklyHoursForSingleVenue(with: json, for: venueName)
        }
        
        if !Storage.fileExists(DiningVenue.directory, in: .caches) {
            let mapping = getIdMapping(jsonArray: jsonArray)
            Storage.store(mapping, to: .caches, as: DiningVenue.directory)
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
        
        var closedFlag = false
        var closedTime: OpenClose?
        
        for json in timesJSON {
            guard let type = json["type"].string, type == "Lunch" || type == "Brunch" || type == "Dinner" || type == "Breakfast" || type == "Late Night" || type == "Closed" || name.range(of: type) != nil, let open = json["open"].string, let close = json["close"].string else { continue }
            
            let longFormatter = DateFormatter()
            longFormatter.dateFormat = "yyyy-MM-dd"
            let todayString = longFormatter.string(from: Date())
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd:HH:mm:ss"
            formatter.timeZone = TimeZone(abbreviation: "EST")
            
            let openString = todayString + ":" + open
            let closeString = todayString + ":" + close
            
            guard let openDate = formatter.date(from: openString)?.adjustedFor11_59,
                  let closeDate = formatter.date(from: closeString)?.adjustedFor11_59 else { continue }
            
            let time = OpenClose(open: openDate, close: closeDate, meal: type)
            if type == "Closed" {
                closedFlag = true
                closedTime = time
            } else if !hours.containsOverlappingTime(with: time) {
                hours.append(time)
            }
        }
        
        if let closedTime = closedTime, closedFlag {
            hours = hours.filter { !$0.overlaps(with: closedTime) }
        }
        
        self.load(hours: hours, for: venueName)
    }
    
    fileprivate func loadWeeklyHoursForSingleVenue(with json: JSON, for venue: DiningVenueName) -> Bool {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(OpenClose.dateFormatter())
        do {
            let decodedHours = try decoder.decode(DiningVenueForWeek.self, from: json.rawData())
            dump(decodedHours)
        } catch {
            print(error)
            return false
        }
        return true
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

extension DiningAPI {
    func fetchHardcodedData(_ completion: @escaping (_ success: Bool) -> Void) {
        if let filePath = Bundle.main.path(forResource: "diningJSON", ofType: "json"),
            let data = NSData(contentsOfFile: filePath) {
            let json = try! JSON(data: data as Data)
            let success: Bool = DiningHoursData.shared.loadHardcodedData(for: json)
            completion(success)
        }
    }
}

extension DiningHoursData {
    fileprivate func loadHardcodedData(for json: JSON) -> Bool {
        guard let jsonArray = json["venues"].array else {
            return false
        }
        
        for json in jsonArray {
            loadHardcodedHoursForSingleVenue(for: json)
        }
        return true
    }
    
    fileprivate func loadHardcodedHoursForSingleVenue(for json: JSON) {
        guard let name = json["name"].string, let scheduleJSON = json["schedule"].array else {
            return
        }
        let venueName = DiningVenueName.getVenueName(for: name)
        if venueName == .unknown {
            return
        }
        
        let today: String = Date().dayOfWeek
        var mealsJSON: [JSON]!
        for json in scheduleJSON {
            let day = json["day"].stringValue
            if today == day {
                mealsJSON = json["meals"].array
            }
        }
        
        if mealsJSON == nil {
            return
        }
        
        var hours = [OpenClose]()
        
        let formatter = DateFormatter()
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.dateFormat = "h:mma"
        formatter.timeZone = TimeZone(abbreviation: "EST")
        
        for json in mealsJSON {
            let start = json["start"].stringValue
            let end = json["end"].stringValue
            let type = json["type"].stringValue
            
            guard let openDate = formatter.date(from: start)?.adjustedFor11_59, let closeDate = formatter.date(from: end)?.adjustedFor11_59 else { continue }
            
            let time = OpenClose(open: openDate, close: closeDate, meal: type)
            hours.append(time)
        }
        
        self.load(hours: hours, for: venueName)
    }
}

