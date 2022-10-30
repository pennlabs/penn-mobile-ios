//
//  CoursesProvider.swift
//  PennMobile
//
//  Created by Anthony Li on 10/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import WidgetKit

struct CoursesEntry: TimelineEntry {
    let date: Date
    let courses: [Course]?
    
    var weekday: Int {
        Course.calendar.component(.weekday, from: date) + 1
    }
    
    var time: Int {
        Course.calendar.component(.hour, from: date) * 60 + Course.calendar.component(.minute, from: date)
    }
}

struct CoursesProvider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (CoursesEntry) -> Void) {
        completion(CoursesEntry(date: Date(), courses: nil))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CoursesEntry>) -> Void) {
        completion(Timeline(entries: [CoursesEntry(date: Date(), courses: nil)], policy: .never))
    }
    
    func placeholder(in context: Context) -> CoursesEntry {
        CoursesEntry(date: Date(), courses: nil)
    }
}
