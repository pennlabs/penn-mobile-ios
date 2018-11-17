//
//  Event.swift
//  PennMobile
//
//  Created by Carin Gan on 11/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class Event {
    let name: String
    let club: String
    let imageUrl: String
    let description: String
    let startTime: Date
    let endTime: Date
    let location: String
    let website: String?
    
    init(name: String, club: String, imageUrl: String, description: String, startTime: Date, endTime: Date, location: String, website: String?) {
        self.name = name
        self.club = club
        self.imageUrl = imageUrl
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.website = website
    }
    
    func timeDescription() -> String {
        return startTime.description + " to " + endTime.description
    }
    
    static func getDefaultEvent() -> Event {
        let name = "Thanksgiving BYO"
        let club = "Penn Labs"
        let imageUrl = "https://theromehello.com/wp-content/uploads/2018/03/Latinas-Who-Travel-Meet-ups-and-Events.jpg"
        let description =  "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
        let startTimeStr = "2018-04-01T17:00:00-05:00"
        let endTimeStr = "2018-04-01T17:20:00-05:00"
        let location = "JMHH 365"
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let startTime = formatter.date(from: startTimeStr)!
        let endTime = formatter.date(from: endTimeStr)!
        
        return Event(name: name, club: club, imageUrl: imageUrl, description: description, startTime: startTime, endTime: endTime, location:location, website: "http://www.penndischord.com/")
    }
}

// MARK: - JSON Parsing
extension Event {
    convenience init(json: JSON) throws {
        guard let name = json["name"].string,
            let club = json["club"].string,
            let description = json["description"].string,
            let imageUrl = json["image_url"].string,
            let startTimeStr = json["start_time"].string,
            let endTimeStr = json["end_time"].string,
            let location = json["location"].string else {
                throw NetworkingError.jsonError
        }
        
        var website = json["website"].string
        
        // Check if valid website
        if let unwrappedWebsite = website, URL(string: unwrappedWebsite) == nil {
            website = nil
        }
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        
        guard let startTime = formatter.date(from: startTimeStr), let endTime = formatter.date(from: endTimeStr) else {
            throw NetworkingError.jsonError
        }
        
        self.init(name: name, club: club, imageUrl: imageUrl, description: description, startTime: startTime, endTime: endTime, location: location, website: website)
    }
}

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.name == rhs.name
            && lhs.club == rhs.club
            && lhs.imageUrl == rhs.imageUrl
            && lhs.description == rhs.description
            && lhs.startTime == rhs.startTime
            && lhs.endTime == rhs.endTime
            && lhs.location == rhs.location
            && lhs.website == rhs.website
    }
}

extension Array where Element == Event {
    func equals(_ arr: [Event]) -> Bool {
        if arr.count != count {
            return false
        }
        
        for i in 0..<(count) {
            if self[i] != arr[i] {
                return false
            }
        }
        return true
    }
}
