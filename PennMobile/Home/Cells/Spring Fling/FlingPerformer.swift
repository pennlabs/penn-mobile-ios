//
//  FlingPerformer.swift
//  PennMobile
//
//  Created by Josh Doman on 3/9/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class FlingPerformer {
    let name: String
    let image: UIImage
    let description: String
    let startTime: Date
    let endTime: Date
    
    init(name: String, image: UIImage, description: String, startTime: Date, endTime: Date) {
        self.name = name
        self.image = image
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
    }
    
    static func getDefaultPerformer() -> FlingPerformer {
        let name = "The Dining Philosopher's"
        let image = UIImage(named: "band_example")!
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
        
        return FlingPerformer(name: name, image: image, description: description, startTime: startTime, endTime: endTime)
    }
}
