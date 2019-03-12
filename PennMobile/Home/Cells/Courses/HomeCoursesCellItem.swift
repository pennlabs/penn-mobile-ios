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
        self.courses = courses
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
//        let defaultCourse = Course(name: "Strategic Cost Analysis", term: "2019A", code: "ACCT-102", section: "003", building: "MEYH", room: "255", weekdays: "MW", startDate: "", endDate: "", startTime: "", endTime: "", instructors: ["Matthew J. Bloomfield"])
        guard let json = json, let data: Data = try? json.rawData()  else { return nil }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let courses = try decoder.decode([Course].self, from: data)
            return HomeCoursesCellItem(courses: courses)
        } catch {
            return nil
        }
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
