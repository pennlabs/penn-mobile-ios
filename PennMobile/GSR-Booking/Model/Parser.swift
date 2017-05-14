//
//  Parser.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation

class Parser {
    static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    static let midnight: Date = getDateFromTime(time: "12:00am")
    
    static func parseJSON(_ JSON: Any) -> NSDictionary {
        return JSON as! NSDictionary
    }
    
    static func getDateFromTime(time: String) -> Date {
        return formatter.date(from: time)!
    }
    
    static func getAvailableTimeSlots(_ rawHTML : String) -> Dictionary<String, [GSRHour]> {
        var timeSlots = Dictionary<String, [GSRHour]>()
        
        let aTags = getATags(rawHTML) as NSArray
        
        for tag in aTags {
            
            let (room, start, end) = getRoomAndHours(tag as! String)
            
            var roomHours = [GSRHour]()
            
            if let hours = timeSlots[room] {
                roomHours = hours
            }
            
            let id = getAttributeFromTag("id", rawTag: tag as! String)
            
            let hour = GSRHour(id: Int(id)!, start: start, end: end, prev: nil)
            
            let index = roomHours.count
            
            if (index > 0) {
                
                let prev = roomHours[index - 1]
                
                if (hour.id == prev.id + 1) {
                    hour.prev = prev
                    prev.next = hour
                }
            }
            
            roomHours.append(hour)
            timeSlots[room] = roomHours
        }
        return timeSlots
    }
    
    fileprivate static func getATags(_ rawHTML : String) -> [String] {
        return matchesForRegexInText("<a href=\"#\" class=\"lc_rm_a\".[^<]*</a>", text:rawHTML)
    }
    
    fileprivate static func getAttributeFromTag(_ attribute : String, rawTag : String) -> String{
        return matchesForRegexInText("\(attribute)=\"[^\"]*\"", text:rawTag)[0]
        .replacingOccurrences(of: "\(attribute)=", with: "")
        .replacingOccurrences(of: "\"", with: "")
    }
    
    fileprivate static func getRoomAndHours(_ tag : String) ->  (String, String, String) {
        let details = getAttributeFromTag("title", rawTag: tag).components(separatedBy: ",")
        
        let room = details[0]
        
        let timeRange : [String]
        
        if details[1] == " 3rd floor Evans" {
            timeRange = details[2].components(separatedBy: " to ")
        } else {
            timeRange = details[1].components(separatedBy: " to ")
        }
        
        //safe, avoid index out of bound NEED TO FIX
        if timeRange.count > 1 {
            let start = timeRange[0]
            let end = timeRange[1]
            return (room, start, end)
        }
        
        return (room, "", "")
    }
    
    static func idsArrayToString(_ ids : [Int]) -> String {
        return ids.map({"\($0)"}).joined(separator: "|")
    }
    
    fileprivate static func matchesForRegexInText(_ regex: String, text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                                                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch _ as NSError {
//            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    static func dataStringToSAMLResponse(_ dataString : String) -> String {
        let matches = matchesForRegexInText("<input type=\"hidden\" name=\"SAMLResponse\".[^<]*/>", text:dataString)
        
        if (matches.count > 0) {
            let match = matches[0]
            return getAttributeFromTag("value", rawTag: match).replacingOccurrences(of: "=", with: "%3D").replacingOccurrences(of: "+", with: "%2B")
        }
        
        return ""
    }
    
}
