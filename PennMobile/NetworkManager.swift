//
//  NetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 2/18/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation

class NetworkManager {
    
    static let masterURL = "https://api.pennlabs.org/"
    
    static let weatherURL = masterURL + "weather"
    static let announcementURL = masterURL + "calendar"
    static let diningURL = masterURL + "dining/venues"
        
    //callback gives a dict with "temp" and "description"
    static func getWeatherData(callback: @escaping (_ info: [String: AnyObject]) -> ()) {
        getRequest(url: weatherURL, callback: { (data) in
            
            var infoDict = [String: AnyObject]()
            
            if let dict = data as? [String: AnyObject] {
                if let array: AnyObject = dict["weather_data"] {
                    
                    if let dictionary = array as? [String: AnyObject] {
                        if let mainDict = dictionary["main"] as? [String: AnyObject] {
                            if let temp = mainDict["temp"] as? Int {
                                infoDict["temp"] = temp as AnyObject
                            }
                        }
                        
                        if let weatherArray = dictionary["weather"] as? [AnyObject] {
                            for dictionary in weatherArray {
                                if let dictionary = dictionary as? [String: AnyObject], let description = dictionary["description"] {
        
                                    infoDict["description"] = description
                                }
                            }
                        }
                    }
                }
                
                callback(infoDict)
            } else {
                print("Results key not found in dictionary")
            }
        
        })
    }
    
    public static func getAnnouncementData(callback: @escaping (_ announcements: [Announcement]) -> ()) {
        getRequest(url: announcementURL) { (data) in
            
            var announcements = [Announcement]()
            
            if let dict = data as? [String: AnyObject] {
                if let array = dict["calendar"] as? [AnyObject] {
                    
                    for event in array {
                        if let eventDict = event as? [String: AnyObject] {
                            
                            if let start = eventDict["start"] as? String, let end = eventDict["end"] as? String, let title = eventDict["name"] as? String {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                
                                if let startDate = dateFormatter.date(from: start), let endDate = dateFormatter.date(from: end) {
                                    announcements.append(Announcement(title: title, start: startDate, end: endDate))
                                }
                            }
                            
                        }
                    }
                }

            }
            
            callback(announcements)
            
        }
    }
    
    public static func getDiningData(for diningHalls: [DiningHall], callback: @escaping (_ diningHalls: [DiningHall]) -> ()) {
        getRequest(url: diningURL) { (data) in
            
            var info = [String: AnyObject]()
            
            for hall in diningHalls {
                info[hall.name] = getOpenCloseTimes(for: hall.name, data: data) as AnyObject
            }
            
            let updatedDiningHalls = getDiningHallFromData(info: info, diningHalls: diningHalls)
            
            callback(updatedDiningHalls)
            
        }
    }
    
    private static func getDiningHallFromData(info: [String: AnyObject], diningHalls: [DiningHall]) -> [DiningHall] {
        var newDiningHalls = [DiningHall]()
        
        let today = Date.currentLocalDate //get current time in local time
        
        for var hall in diningHalls {
            hall.timeRemaining = 0 //set default time remaining to be zero (closed)
            
            var openingTimes = [OpenClose]()
            
            if let times = info[hall.name] as? [String: AnyObject] {
                for obj in times.values {
                    if let timeDict = obj as? [String: Date] {
                        
                        if let open = timeDict["open"], let close = timeDict["close"] {
                            if today >= open && today < close {
                                hall.timeRemaining = today.minutesFrom(date: close) //minutes till close
                            }
                            openingTimes.append(OpenClose(open: open, close: close))
                        }
                    }
                }
            }
            
            openingTimes.sort(by: { (oc1, oc2) -> Bool in
                return oc1.open < oc2.open
            })
            
            hall.times = openingTimes
            newDiningHalls.append(hall)
        }
        
        return newDiningHalls
    }
    
    private static func getOpenCloseTimes(for diningHall: String, data: NSDictionary?) -> [String: AnyObject] {
        var info = [String: AnyObject]()
        let diningHall = diningHall.folding(options: .diacriticInsensitive, locale: .current) //removes accents
        if let dict = data as? [String: AnyObject] {
            if let dict2 = dict["document"] as? [String: AnyObject] {
                if let array = dict2["venue"] as? [AnyObject] {
                    for diningHallDict in array {
                        if let diningHallDict = diningHallDict as? [String: AnyObject] {
                            if let name = diningHallDict["name"] as? String {
                                let name = name.folding(options: .diacriticInsensitive, locale: .current)
                                if name.range(of: diningHall) != nil || diningHall.range(of: name) != nil {
                                    
                                    if let dateArray = diningHallDict["dateHours"] as? [AnyObject] {
                                        
                                        let today = Date()
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        
                                        let todayString = dateFormatter.string(from: today)
                                        
                                        for obj in dateArray {
                                            if let dict = obj as? [String: AnyObject] {
                                                
                                                if let date = dict["date"] as? String {
                                                    if date == todayString {
                                                        
                                                        if let array = dict["meal"] as? [AnyObject] {
                                                            
                                                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                                                            dateFormatter.timeZone = TimeZone(abbreviation: "EST")

                                                            for obj in array {
                                                                
                                                                if let mealDict = obj as? [String: AnyObject] {
                                                                    if let type = mealDict["type"] as? String, type == "Lunch" || type == "Brunch" || type == "Dinner" || type == "Breakfast" || type == "Late Night" || diningHall.range(of: type) != nil {
                                                                        
                                                                        if let open = mealDict["open"] as? String, let close = mealDict["close"] as? String {
                                                                            
                                                                            let openDate = dateFormatter.date(from: "\(todayString)T\(open)+0000")?.adjustFor11_59() //rounds up if :59
                                                                            let closeDate = dateFormatter.date(from: "\(todayString)T\(close)+0000")?.adjustFor11_59()
                                                                            
                                                                            info[type] = ["open": openDate, "close": closeDate] as AnyObject
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            break
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return info
    }
    
    private static func getRequest(url: String, callback: @escaping (_ json: NSDictionary?) -> ()) {
        let url = URL(string: url)
        
        let request = NSMutableURLRequest(url: url!)
        
        request.httpMethod = "GET"
        do {
            //let params = ["item":item, "location":location,"username":username]
            
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            //request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                //
                
                
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                    }
                }
                
                //let resultNSString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                if let data = data, let _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    if let json = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        
                        callback(json)
                        
                    }
                } else {
                    callback(nil)
                }
                
            })
            task.resume()
        }
    }
    
}
