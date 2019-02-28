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
    
    enum CodingKeys: String, CodingKey {
        case accountID = "account_id"
        case courses
    }
}

class Course: Codable, Hashable {
    let name: String
    let term: String
    let code: String
    let section: String
    let building: Building?
    let room: String?
    let weekdays: String
    let startTime: String
    let endTime: String
    let instructors: [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case term
        case code
        case section
        case building
        case room
        case weekdays
        case startTime = "start"
        case endTime = "end"
        case instructors
    }
    
    init(name: String, term: String, code: String, section: String, building: Building?, room: String?, weekdays: String, startTime: String, endTime: String, instructors: [String]) {
        self.name = name
        self.term = term
        self.code = code
        self.section = section
        self.instructors = instructors
        self.building = building
        self.room = room
        self.weekdays = weekdays
        self.startTime = startTime
        self.endTime = endTime
    }
    
    var description: String {
        let instructorStr = instructors.joined(separator: ", ")
        let str = "\(term) \(name) \(code)-\(section) \(instructorStr) \(weekdays) \(startTime) \(endTime)"
        if let building = building, let room = room {
            return "\(str) \(building.code) \(room)"
        } else {
            return str
        }
    }
    
    var hashValue: Int {
        return "\(term)\(code)\(section)".hashValue
    }
    
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.term == rhs.term && lhs.code == rhs.code && lhs.section == rhs.section
    }
}
