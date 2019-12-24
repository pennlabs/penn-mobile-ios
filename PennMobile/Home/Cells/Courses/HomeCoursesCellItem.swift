//
//  HomeCoursesCellItem.swift
//  PennMobile
//
//  Created by Josh Doman on 3/11/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

final class HomeCoursesCellItem: HomeCellItem {
    
    static var jsonKey: String {
        return "courses"
    }
    
    let weekday: String
    var courses: [Course]
    
    init(weekday: String, courses: [Course]) {
        self.weekday = weekday
        self.courses = courses.sorted()
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        if let json = json, let weekday = json["weekday"].string, let data: Data = try? json["courses"].rawData() {
            // Courses provided by server
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let courses = try decoder.decode([Course].self, from: data)
                return HomeCoursesCellItem(weekday: weekday, courses: courses)
            } catch {
                return nil
            }
        } else if let courses = UserDefaults.standard.getCourses() {
            // Courses not provided by server. Use courses saved on device.
            let coursesToday = courses.taughtToday
            if !coursesToday.isEmpty {
                let weekday = "Today"
                return HomeCoursesCellItem(weekday: weekday, courses: Array(coursesToday))
            } else {
                let weekday = "Tomorrow"
                let coursesTomorrow = courses.taughtTomorrow
                if !coursesTomorrow.isEmpty {
                    return HomeCoursesCellItem(weekday: weekday, courses: Array(coursesTomorrow))
                } else {
                    return nil
                }
            }
            
        } else {
            return nil
        }
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeCoursesCell.self
    }
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeCoursesCellItem else { return false }
        return weekday == item.weekday
    }
}

// MARK: - Home Page Logic
extension Set where Element == Course {
    var enrolledIn: Set<Course> {
        let nowStr = "2019-10-01"
        let term = Course.currentTerm
        let coursesWithDate = self.filter { $0.startDate != nil && $0.endDate != nil }.filter { $0.startDate! <= nowStr && nowStr <= $0.endDate! }
        let coursesWithoutDate = self.filter { $0.startDate == nil || $0.endDate == nil }.filter { $0.term == term }
        return coursesWithDate.union(coursesWithoutDate)
    }
    
    var taughtToday: Set<Course> {
        self.enrolledIn.filter { $0.isTaughtToday }
    }
    
    var taughtTomorrow: Set<Course> {
        self.enrolledIn.filter { $0.isTaughtTomorrow }
    }
}
