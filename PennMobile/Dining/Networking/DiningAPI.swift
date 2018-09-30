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
            // comment
            
            guard let openDate = formatter.date(from: start)?.adjustedFor11_59, let closeDate = formatter.date(from: end)?.adjustedFor11_59 else { continue }
            
            let time = OpenClose(open: openDate, close: closeDate, meal: type)
            hours.append(time)
        }
        
        self.load(hours: hours, for: venueName)
    }
}

