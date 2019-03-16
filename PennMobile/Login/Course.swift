//
//  Course.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct CoursesJSON: Codable {
    let accountID: String
    let courses: Set<Course>
}

class Course: Codable, Hashable {
    let name: String
    let term: String
    let dept: String
    let code: String
    let section: String
    let building: String?
    let room: String?
    let weekdays: String
    let startDate: String
    let endDate: String
    let startTime: String
    let endTime: String
    let instructors: [String]
    
    init(name: String, term: String, dept: String, code: String, section: String, building: String?, room: String?, weekdays: String, startDate: String, endDate: String, startTime: String, endTime: String, instructors: [String]) {
        self.name = name
        self.term = term
        self.dept = dept
        self.code = code
        self.section = section
        self.instructors = instructors
        self.building = building
        self.room = room
        self.weekdays = weekdays
        self.startDate = startDate
        self.endDate = endDate
        self.startTime = startTime
        self.endTime = endTime
    }
    
    var description: String {
        let instructorStr = instructors.joined(separator: ", ")
        let str = "\(term) \(name) \(dept)-\(code)-\(section) \(instructorStr) \(weekdays) \(startDate) - \(endDate) \(startTime) \(endTime)"
        if let building = building, let room = room {
            return "\(str) \(building) \(room)"
        } else {
            return str
        }
    }
    
    var hashValue: Int {
        return "\(term)\(dept)\(code)\(section)".hashValue
    }
    
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.term == rhs.term && lhs.code == rhs.code && lhs.section == rhs.section
    }
    
    func getEvent() -> Event? {
        guard let startTime = getTime(from: startTime), let endTime = getTime(from: endTime) else { return nil }
        var location: String? = nil
        if let building = building, let room = room {
            location = "\(building) \(room)"
        }
        return Event(name: "\(dept)\(code)", location: location, startTime: startTime, endTime: endTime)
    }
    
    private func getTime(from str: String) -> Time? {
        guard let hourStr = str.getMatches(for: "^(.*?):").first, let hour = Int(String(hourStr)) else { return nil }
        guard let minuteStr = str.getMatches(for: ":(.*?) ").first, let minutes = Int(String(minuteStr)) else { return nil }
        guard let amStr = str.getMatches(for: " (.*?)$").first else { return nil }
        return Time(hour: hour, minutes: minutes, isAm: amStr == "AM")
    }
}
