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
    
    let courses: [Course]
    
    init(courses: [Course]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        self.courses = courses.sorted(by: { (c1, c2) -> Bool in
            let date1 = formatter.date(from: c1.startTime)
            let date2 = formatter.date(from: c2.startTime)
            if date1 == nil { return true }
            if date2 == nil { return false }
            return date1! < date2!
        })
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
//        let defaultCourse = Course(name: "Strategic Cost Analysis", term: "2019A", code: "ACCT-102", section: "003", building: "MEYH", room: "255", weekdays: "MW", startDate: "", endDate: "", startTime: "", endTime: "", instructors: ["Matthew J. Bloomfield"])
        guard let json = json, let data: Data = try? json.rawData()  else { return getFakeItem() }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let courses = try decoder.decode([Course].self, from: data)
            return HomeCoursesCellItem(courses: courses)
        } catch {
            return nil
        }
    }
    
    private static func getFakeItem() -> HomeCellItem? {
        guard let student = Student.getStudent(), let courses = student.courses else { return nil }
        let todaysCourses = courses.filter { (course) -> Bool in
            course.term.contains("2019A") && course.weekdays.contains("T")
        }
        return HomeCoursesCellItem(courses: Array(todaysCourses))
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeCoursesCell.self
    }
    
    func equals(item: HomeCellItem) -> Bool {
        guard let item = item as? HomeCoursesCellItem else { return false }
        let courses = self.courses
        let itemCourses = item.courses
        return courses == itemCourses
    }
}
