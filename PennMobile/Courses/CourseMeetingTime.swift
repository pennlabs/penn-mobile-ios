//
//  CourseLocation.swift
//  PennMobile
//
//  Created by Josh Doman on 3/18/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct CourseMeetingTime: Codable {
    let building: String?
    let room: String?
    let weekday: String
    let startTime: String
    let endTime: String

    var description: String {
        var str = "\(weekday) \(startTime) \(endTime)"
        if let room = room {
            str = "\(room) \(str)"
        }
        if let building = building {
            str = "\(building) \(str)"
        }
        return str
    }
}
