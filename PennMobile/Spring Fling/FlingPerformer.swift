//
//  FlingPerformer.swift
//  PennMobile
//
//  Created by Josh Doman on 3/9/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class FlingPerformer {
    let name: String
    let imageUrl: String
    let description: String
    let startTime: Date
    let endTime: Date
    
    init(name: String, imageUrl: String, description: String, startTime: Date, endTime: Date) {
        self.name = name
        self.imageUrl = imageUrl
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
    }
    
    static func getDefaultPerformer() -> FlingPerformer {
        let name = "The Dining Philosopher's"
        let imageUrl = "https://s3.amazonaws.com/event.editor/events/images/000/000/004/original/band_example.jpg?1521240775"
        let description = "A group of fun loving Jazz musicians from Penn Labs - Josh Doman, Dominic Holmes, Tiffany Chang, and more."
        let startTimeStr = "2018-04-01T17:00:00-05:00"
        let endTimeStr = "2018-04-01T17:20:00-05:00"
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let startTime = formatter.date(from: startTimeStr)!
        let endTime = formatter.date(from: endTimeStr)!
        
        return FlingPerformer(name: name, imageUrl: imageUrl, description: description, startTime: startTime, endTime: endTime)
    }
}
