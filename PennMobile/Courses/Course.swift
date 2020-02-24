//
//  Course.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct CoursesJSON: Codable {
    let id: String
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
    let startDate: String?
    let endDate: String?
    let startTime: String
    let endTime: String
    let instructors: [String]
    
    let meetingTimes: [CourseMeetingTime]?
    
    init(name: String, term: String, dept: String, code: String, section: String, building: String?, room: String?, weekdays: String, startDate: String?, endDate: String?, startTime: String, endTime: String, instructors: [String], meetingTimes: [CourseMeetingTime]?) {
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
        self.meetingTimes = meetingTimes
    }
    
    var description: String {
        let instructorStr = instructors.joined(separator: ", ")
        var str = "\(term) \(name) \(dept)-\(code)-\(section) \(instructorStr) \(weekdays) \(startTime) \(endTime)"
        if let startDate = startDate, let endDate = endDate {
            str = " \(str) \(startDate) - \(endDate)"
        }
        
        if let building = building, let room = room {
            str = "\(str) \(building) \(room)"
        }
        if let meetingTimes = meetingTimes {
            for meeting in meetingTimes {
                str = str + "\n\(meeting.description)"
            }
        }
        return str
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(term)
        hasher.combine(dept)
        hasher.combine(code)
        hasher.combine(section)
    }
    
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.term == rhs.term && lhs.dept == rhs.dept && lhs.code == rhs.code && lhs.section == rhs.section
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

extension Course {
    static var weekdayAbbreviations: [String] {
        return ["S", "M", "T", "W", "R", "F", "S"]
    }
    
    static var weekdayFullName: [String] {
        return ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    }
    
    var isTaughtToday: Bool {
        get {
            return isTaughtInNDays(days: 0)
        }
    }
    
    var isTaughtTomorrow: Bool {
        get {
            return isTaughtInNDays(days: 1)
        }
    }
    
    func isTaughtInNDays(days: Int) -> Bool {
        let weekday = Date().integerDayOfWeek
        if let times = meetingTimes {
            let weekday = Course.weekdayAbbreviations[(weekday + days) % 7]
            return times.contains { $0.weekday.contains(weekday) }
        } else {
            return weekdays.contains(Course.weekdayAbbreviations[(weekday + days) % 7])
        }
    }
    
    func hasSameMeetingTime(as course: Course) -> Bool {
        return startTime == course.startTime && endTime == course.endTime && building == course.building && room == course.room
    }
}

extension Course: Comparable {
    static func < (lhs: Course, rhs: Course) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date1 = formatter.date(from: lhs.startTime)
        let date2 = formatter.date(from: rhs.startTime)
        if date1 == nil { return true }
        if date2 == nil { return false }
        return date1! < date2!
    }
}

extension Array where Element == Course {
    // weekday: "Today", "Tomorrow", "Monday", "Tuesday", etc.
    func filterByWeekday(for fullWeekday: String) -> [Course] {
        var courses = [Course]()
        let weekdayAbbr = weekdayMapping(for: fullWeekday)
        for course in self {
            if let meetingTimes = course.meetingTimes {
                for meetingTime in meetingTimes {
                    if meetingTime.weekday == weekdayAbbr {
                        let courseEvent = Course(name: course.name, term: course.term, dept: course.dept, code: course.code, section: course.section, building: meetingTime.building, room: meetingTime.room, weekdays: weekdayAbbr, startDate: course.startDate, endDate: course.endDate, startTime: meetingTime.startTime, endTime: meetingTime.endTime, instructors: course.instructors, meetingTimes: nil)
                        courses.append(courseEvent)
                    }
                }
            }
        }
        return courses
    }
    
    private func weekdayMapping(for weekday: String) -> String {
        switch weekday {
        case "Monday":
            return "M"
        case "Tuesday":
            return "T"
        case "Wednesday":
            return "W"
        case "Thursday":
            return "R"
        case "Friday":
            return "F"
        case "Saturday":
            return "S"
        case "Sunday":
            return "S"
        case "Today":
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            return weekdayMapping(for: dateFormatter.string(from: Date()))
        case "Tomorrow":
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            return weekdayMapping(for: dateFormatter.string(from: Date().tomorrow))
        default:
            return ""
        }
    }
    
    func equalsCourseEvents(_ courses: [Course]) -> Bool {
        for c1 in courses {
            var exists = false
            let courseCandidates = self.filter { c1 == $0 }
            for course in courseCandidates {
                if c1.hasSameMeetingTime(as: course) {
                    exists = true
                }
            }
            
            if !exists {
                return false
            }
        }
        
        for c2 in self {
            var exists = false
            let courseCandidates = courses.filter { c2 == $0 }
            for course in courseCandidates {
                if c2.hasSameMeetingTime(as: course) {
                    exists = true
                }
            }
            
            if !exists {
                return false
            }
        }
        return true
    }
}

extension Course {
    static var currentTerm: String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: now)
        formatter.dateFormat = "M"
        let month = Int(formatter.string(from: now))!
        let code: String
        if month <= 5 {
            code = "A"
        } else if month >= 8 {
            code = "C"
        } else {
            code = "B"
        }
        return "\(year)\(code)"
    }
}
