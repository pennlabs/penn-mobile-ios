////
////  FlingPerformer.swift
////  PennMobile
////
////  Created by Josh Doman on 3/9/18.
////  Copyright © 2018 PennLabs. All rights reserved.
////
//
//import Foundation
//import SwiftyJSON
//
//final class FlingPerformer {
//    let name: String
//    let imageUrl: String
//    let description: String
//    let startTime: Date
//    let endTime: Date
//    let website: String?
//    
//    init(name: String, imageUrl: String, description: String, startTime: Date, endTime: Date, website: String?) {
//        self.name = name
//        self.imageUrl = imageUrl
//        self.description = description
//        self.startTime = startTime
//        self.endTime = endTime
//        self.website = website
//    }
//    
//    static func getDefaultPerformer() -> FlingPerformer {
//        let name = "The Dining Philosopher's"
//        let imageUrl = "https://s3.amazonaws.com/event.editor/events/images/000/000/004/original/band_example.jpg?1521240775"
//        let description = "A group of fun loving Jazz musicians from Penn Labs - Josh Doman, Dominic Holmes, Tiffany Chang, and more."
//        let startTimeStr = "2018-04-01T17:00:00-05:00"
//        let endTimeStr = "2018-04-01T17:20:00-05:00"
//        
//        let formatter = DateFormatter()
//        formatter.calendar = Calendar(identifier: .iso8601)
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        
//        let startTime = formatter.date(from: startTimeStr)!
//        let endTime = formatter.date(from: endTimeStr)!
//        
//        return FlingPerformer(name: name, imageUrl: imageUrl, description: description, startTime: startTime, endTime: endTime, website: "http://www.penndischord.com/")
//    }
//}
//
//// MARK: - JSON Parsing
//extension FlingPerformer {
//    convenience init(json: JSON) throws {
//        guard let name = json["name"].string,
//            let description = json["description"].string,
//            let imageUrl = json["image_url"].string,
//            let startTimeStr = json["start_time"].string,
//            let endTimeStr = json["end_time"].string else {
//                throw NetworkingError.jsonError
//        }
//        
//        var website = json["website"].string
//        
//        // Check if valid website
//        if let unwrappedWebsite = website, URL(string: unwrappedWebsite) == nil {
//            website = nil
//        }
//        
//        let formatter = DateFormatter()
//        formatter.calendar = Calendar(identifier: .iso8601)
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
//        
//        guard let startTime = formatter.date(from: startTimeStr), let endTime = formatter.date(from: endTimeStr) else {
//            throw NetworkingError.jsonError
//        }
//        
//        self.init(name: name, imageUrl: imageUrl, description: description, startTime: startTime, endTime: endTime, website: website)
//    }
//}
//
//extension FlingPerformer: Equatable {
//    static func == (lhs: FlingPerformer, rhs: FlingPerformer) -> Bool {
//        return lhs.name == rhs.name
//            && lhs.imageUrl == rhs.imageUrl
//            && lhs.description == rhs.description
//            && lhs.startTime == rhs.startTime
//            && lhs.endTime == rhs.endTime
//            && lhs.website == rhs.website
//    }
//}
//
//extension Array where Element == FlingPerformer {
//    func equals(_ arr: [FlingPerformer]) -> Bool {
//        if arr.count != count {
//            return false
//        }
//        
//        for i in 0..<(count) {
//            if self[i] != arr[i] {
//                return false
//            }
//        }
//        return true
//    }
//}
