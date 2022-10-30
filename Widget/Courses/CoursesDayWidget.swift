//
//  CoursesWidget.swift
//  PennMobile
//
//  Created by Anthony Li on 10/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import WidgetKit
import SwiftUI

private struct CoursesDayWidgetSchedule: View {
    var entry: CoursesEntry
    
    var body: some View {
        Group {
            if let courses = entry.courses {
                let scheduleEntries = courses.entries(for: entry.weekday)
                if scheduleEntries.isEmpty {
                    Text("You have no classes today 🎉")
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                } else if !scheduleEntries.contains(where: {
                    entry.time < $0.meetingTime.endTime
                }) {
                    Text("You have no more classes today 🎉")
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                } else {
                    Rectangle()
                        .fill(.clear)
                        .overlay(alignment: .top) {
                            ScheduleView(entries: scheduleEntries)
                        }
                        
                }
            } else {
                Text("Open the Penn Mobile app to see your courses on this widget.").multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CoursesDayWidgetView: View {
    var entry: CoursesEntry
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Course.calendar
        formatter.timeZone = Course.timezone
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Course.calendar
        formatter.timeZone = Course.timezone
        formatter.setLocalizedDateFormatFromTemplate("EE")
        return formatter
    }()
    
    static let dateNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dd")
        return formatter
    }()
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        Group {
            switch widgetFamily {
            case .systemLarge:
                VStack {
                    Text("\(entry.date, formatter: CoursesDayWidgetView.dateFormatter)")
                        .fontWeight(.medium)
                    CoursesDayWidgetSchedule(entry: entry)
                }
            case .systemMedium:
                HStack(alignment: .top) {
                    VStack {
                        Text("\(entry.date, formatter: CoursesDayWidgetView.dayOfWeekFormatter)")
                            .fontWeight(.medium)
                            .textCase(.uppercase)
                        Text("\(entry.date, formatter: CoursesDayWidgetView.dateNumberFormatter)")
                            .font(.largeTitle)
                    }.frame(minWidth: 50, alignment: .leading)
                    CoursesDayWidgetSchedule(entry: entry)
                }
            case .systemSmall:
                CoursesDayWidgetSchedule(entry: entry)
            default:
                Text("Unsupported")
            }
        }.padding()
    }
}

struct CoursesDayWidget: Widget {
    static let kind = "Courses"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: CoursesDayWidget.kind, provider: CoursesProvider()) { entry in
            CoursesDayWidgetView(entry: entry)
        }
        .configurationDisplayName("Course Schedule")
        .description("Your upcoming courses, at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

private let dummyCourses = [
    Course(dummyCourseWithCode: "CIS 1600", title: "Drowning in Proofs", section: "123", location: "ABCD 1234", startHour: 12, startMinute: 0, endHour: 14, endMinute: 0),
    Course(dummyCourseWithCode: "CIS 1200", title: "What if programming but camels?", section: "123", location: "ABCD 1234", startHour: 14, startMinute: 15, endHour: 15, endMinute: 45)
]

struct CoursesDayWidget_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            CoursesDayWidgetView(entry: CoursesEntry(date: Course.calendar.startOfDay(for: Date()), courses: dummyCourses))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Dummy courses")
            CoursesDayWidgetView(entry: CoursesEntry(date: Date(), courses: []))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("No courses")
            CoursesDayWidgetView(entry: CoursesEntry(date: Date(), courses: nil))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Prompt to open")
        }
    }
}
