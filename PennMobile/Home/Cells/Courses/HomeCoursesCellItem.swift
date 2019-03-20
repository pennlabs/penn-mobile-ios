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
    let courses: [Course]
    
    init(weekday: String, courses: [Course]) {
        self.weekday = weekday
        
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
        guard let json = json, let weekday = json["weekday"].string, let data: Data = try? json["courses"].rawData()  else { return nil }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let courses = try decoder.decode([Course].self, from: data)
            return HomeCoursesCellItem(weekday: weekday, courses: courses)
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
