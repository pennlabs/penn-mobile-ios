//
//  CoursesProvider.swift
//  PennMobile
//
//  Created by Anthony Li on 10/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import WidgetKit
import Intents

struct CoursesEntry<Configuration>: TimelineEntry {
    let date: Date
    let courses: [Course]?
    let configuration: Configuration
    
    var weekday: Int {
        Course.calendar.component(.weekday, from: date)
    }
    
    var time: Int {
        Course.calendar.component(.hour, from: date) * 60 + Course.calendar.component(.minute, from: date)
    }
}

extension CoursesEntry where Configuration == Void {
    init(date: Date, courses: [Course]?) {
        self.init(date: date, courses: courses, configuration: ())
    }
}

private func getCourses() -> [Course]? {
    do {
        return try Storage.retrieveThrowing(Course.cacheFileName, from: .groupCaches, as: [Course].self)
    } catch let error {
        print("Couldn't load courses: \(error)")
        return nil
    }
}

private func snapshot<Configuration>(configuration: Configuration) -> CoursesEntry<Configuration> {
    return CoursesEntry(date: Date(), courses: getCourses(), configuration: configuration)
}

private func timeline<Configuration>(configuration: Configuration) -> Timeline<CoursesEntry<Configuration>> {
    let today = Course.calendar.startOfDay(for: Date())
    let tomorrow = Course.calendar.date(byAdding: .day, value: 1, to: today)!
    let courses = getCourses()
    let dates: Set<Date>
    
    if let courses {
        let weekday = Course.calendar.component(.weekday, from: today)
        let times = courses.flatMap {
            $0.meetingTimes?.filter {
                $0.weekday == weekday
            }.flatMap {
                [$0.startTime, $0.endTime]
            } ?? []
        }.sorted()
        dates = Set([today] + times.compactMap {
            Course.calendar.date(bySettingHour: $0 / 60, minute: $0 % 60, second: 0, of: today)
        } + [tomorrow])
    } else {
        dates = [today, tomorrow]
    }
    
    return Timeline(entries: dates.sorted().map {
        CoursesEntry(date: $0, courses: courses, configuration: configuration)
    }, policy: .atEnd)
}

struct CoursesProvider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (CoursesEntry<Void>) -> Void) {
        completion(snapshot(configuration: ()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CoursesEntry<Void>>) -> Void) {
        completion(timeline(configuration: ()))
    }
    
    func placeholder(in context: Context) -> CoursesEntry<Void> {
        CoursesEntry(date: Date(), courses: nil)
    }
}

struct IntentCoursesProvider<Intent: INIntent & ConfigurationRepresenting>: IntentTimelineProvider {
    let placeholderConfiguration: Intent.Configuration

    func getSnapshot(for intent: Intent, in context: Context, completion: @escaping (CoursesEntry<Intent.Configuration>) -> Void) {
        completion(snapshot(configuration: intent.configuration))
    }
    
    func getTimeline(for intent: Intent, in context: Context, completion: @escaping (Timeline<CoursesEntry<Intent.Configuration>>) -> Void) {
        completion(timeline(configuration: intent.configuration))
    }
    
    func placeholder(in context: Context) -> CoursesEntry<Intent.Configuration> {
        CoursesEntry(date: Date(), courses: nil, configuration: placeholderConfiguration)
    }
}
