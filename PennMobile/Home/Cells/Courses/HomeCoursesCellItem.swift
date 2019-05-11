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
    
    func equals(item: ModularTableViewItem) -> Bool {
        guard let item = item as? HomeCoursesCellItem else { return false }
        return weekday == item.weekday
    }
}
