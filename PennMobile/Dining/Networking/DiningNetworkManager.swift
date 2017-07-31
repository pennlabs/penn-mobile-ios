//
//  DiningNetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 5/3/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

class DiningNetworkManager: NSObject, Requestable {
    
    static let shared = DiningNetworkManager()
    
    let masterURL = "https://api.pennlabs.org/"
    let diningURL = "dining/venues"
    
    func getDiningData(for diningHalls: [DiningHall], callback: @escaping (_ diningHalls: [DiningHall]) -> ()) {
        let url = masterURL + diningURL
        getRequest(url: url) { (data) in
            
            var info = [String: AnyObject]()
            
            for hall in diningHalls {
                info[hall.name] = self.getOpenCloseTimes(for: hall.name, data: data) as AnyObject
            }
            
            let updatedDiningHalls = self.getDiningHallFromData(info: info, diningHalls: diningHalls)
            
            callback(updatedDiningHalls)
            
        }
    }
    
    private func getDiningHallFromData(info: [String: AnyObject], diningHalls: [DiningHall]) -> [DiningHall] {
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
                            
                            //remove repeat times if any exist
                            let time = OpenClose(open: open, close: close)
                            if !openingTimes.contains(time) {
                                openingTimes.append(time)
                            }
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
    
    private func getOpenCloseTimes(for diningHall: String, data: NSDictionary?) -> [String: AnyObject] {
        var info = [String: AnyObject]()
        let diningHall = diningHall.folding(options: .diacriticInsensitive, locale: .current) //removes accents
        if let dict = data as? [String: AnyObject] {
            if let dict2 = dict["document"] as? [String: AnyObject] {
                if let array = dict2["venue"] as? [AnyObject] {
                    for diningHallDict in array {
                        if let diningHallDict = diningHallDict as? [String: AnyObject], let name = diningHallDict["name"] as? String {
                            let name = name.folding(options: .diacriticInsensitive, locale: .current)
                            if name.range(of: diningHall) != nil || diningHall.range(of: name) != nil {
                                if let dateArray = diningHallDict["dateHours"] as? [AnyObject] {
                                    let dateFormatter = DateFormatter.yyyyMMdd
                                    let todayString = dateFormatter.string(from: Date())
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
                                                                        
                                                                        let openDate = dateFormatter.date(from: "\(todayString)T\(open)+0000")?.adjustedFor11_59 //rounds up if :59
                                                                        let closeDate = dateFormatter.date(from: "\(todayString)T\(close)+0000")?.adjustedFor11_59
                                                                        
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
        return info
    }
}
