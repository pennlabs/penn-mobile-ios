//
//  HomeCoursesCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/11/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeCoursesCellItem: HomeCellItem {
    let weekday: String
    var courses: [Course]
    var isOnHomeScreen: Bool
    
    init(weekday: String, courses: [Course], isOnHomeScreen: Bool) {
        self.weekday = weekday
        self.courses = courses.sorted()
        self.isOnHomeScreen = isOnHomeScreen
    }
    
    static var jsonKey: String {
        return "courses"
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeCoursesCell.self
    }

    static func getHomeCellItem(_ completion: @escaping (([HomeCellItem]) -> Void)) {
        if let courses = UserDefaults.standard.getCourses() {
            let coursesToday = courses.taughtToday
            if coursesToday.hasUpcomingCourse {
                let weekday = "Today"
                return completion([HomeCoursesCellItem(weekday: weekday, courses: Array(coursesToday), isOnHomeScreen: true)])
            } else {
                let weekday = "Tomorrow"
                let coursesTomorrow = courses.taughtTomorrow
                if !coursesTomorrow.isEmpty {
                    return completion([HomeCoursesCellItem(weekday: weekday, courses: Array(coursesTomorrow), isOnHomeScreen: true)])
                } else {
                    return completion([])
                }
            }
        } else {
            return completion([])
        }
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeCoursesCellItem else { return false }
        return weekday == item.weekday
    }
}

// MARK: - Home Page Logic
extension Set where Element == Course {
    var enrolledIn: Set<Course> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let nowStr = formatter.string(from: Date())
        let term = Course.currentTerm
        let coursesWithDate = self.filter { $0.startDate != nil && $0.endDate != nil }.filter { $0.startDate! <= nowStr && nowStr <= $0.endDate! }
        let coursesWithoutDate = self.filter { $0.startDate == nil || $0.endDate == nil }.filter { $0.term == term }
        return coursesWithDate.union(coursesWithoutDate)
    }
    
    var taughtToday: Set<Course> {
        let courses = self.enrolledIn.filter { $0.isTaughtToday }.map { $0.getCourseWithCorrectTime(days: 0) }.flatMap { $0 }
        return Set(courses)
    }
    
    var taughtTomorrow: Set<Course> {
        let courses = self.enrolledIn.filter { $0.isTaughtTomorrow }.map { $0.getCourseWithCorrectTime(days: 1) }.flatMap { $0 }
        return Set(courses)
    }
    
    var hasUpcomingCourse: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let now = formatter.date(from: formatter.string(from: Date()))!
        for course in self {
            if let end = formatter.date(from: course.endTime), now < end {
                return true
            }
        }
        return false
    }
}

extension Course {
    func getCourseWithCorrectTime(days: Int) -> [Course] {
        var courses = [Course]()
        let weekday = Course.weekdayAbbreviations[(Date().integerDayOfWeek + days) % 7]
        if let times = self.meetingTimes {
            for time in times {
                if time.weekday.contains(weekday) {
                    courses.append(self.copy(startTime: time.startTime, endTime: time.endTime))
                }
            }
        }
        if courses.isEmpty {
            return [self]
        } else {
            return courses
        }
    }
    
    func copy(startTime: String, endTime: String) -> Course {
        return Course(name: self.name, term: self.term, dept: self.dept, code: self.code, section: self.section, building: self.building, room: self.room, weekdays: self.weekdays, startDate: self.startDate, endDate: self.endDate, startTime: startTime, endTime: endTime, instructors: self.instructors, meetingTimes: nil)
    }
}
