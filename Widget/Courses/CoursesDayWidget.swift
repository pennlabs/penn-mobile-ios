//
//  CoursesWidget.swift
//  PennMobile
//
//  Created by Anthony Li on 10/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import WidgetKit
import SwiftUI

extension ConfigureCoursesDayWidgetIntent: ConfigurationRepresenting {
    struct Configuration {
        let background: WidgetBackgroundType
    }

    var configuration: Configuration {
        return Configuration(background: background)
    }
}

private struct CelebrationView: View {
    var weekday: Int
    var hadClassesToday: Bool

    var text: Text {
        if weekday == 6 {
            return Text("It's the weekend! 🥳")
        } else if weekday == 1 || weekday == 7 {
            return Text("Enjoy your weekend! 🎉")
        } else if hadClassesToday {
            return Text("You have no more classes today 🎉")
        } else {
            return Text("You have no classes today 🎉")
        }
    }

    var body: some View {
        text
            .fontWeight(.medium)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
    }
}

private struct CoursesDayWidgetSchedule: View {
    var entry: CoursesEntry<ConfigureCoursesDayWidgetIntent.Configuration>

    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.redactionReasons) var redactionReasons

    var isSmall: Bool {
        widgetFamily == .systemSmall
    }

    var body: some View {
        Group {
            if let courses = entry.courses?.filterByDate(entry.date), !courses.isEmpty {
                let scheduleEntries = courses.entries(for: entry.weekday)
                if scheduleEntries.isEmpty {
                    CelebrationView(weekday: entry.weekday, hadClassesToday: false)
                } else if !scheduleEntries.contains(where: {
                    entry.time < $0.meetingTime.endTime
                }) {
                    CelebrationView(weekday: entry.weekday, hadClassesToday: true)
                } else {
                    let minTime = scheduleEntries.filter {
                        entry.time < $0.meetingTime.endTime
                    }.map { $0.meetingTime.startTime }.min()!
                    Rectangle()
                        .fill(.clear)
                        .overlay(alignment: .top) {
                            ScheduleView(entries: scheduleEntries, minTime: minTime - (widgetFamily == .systemLarge ? 0 : 15), maxTime: 24 * 60, hourSize: isSmall ? 64 : 48, hourLabels: isSmall ? .inline : [.inline, .external], showSections: !isSmall, showColors: !entry.configuration.background.prefersGrayscaleContent)
                                .privacySensitive()
                        }
                        .clipShape(Rectangle())

                }
            } else {
                (Text("Go to ") + Text("More › Course Schedule").fontWeight(.bold) + Text(" to use this widget.")).multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CoursesDayWidgetView: View {
    var entry: CoursesEntry<ConfigureCoursesDayWidgetIntent.Configuration>

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

    var courseCount: Int? {
        guard let courses = entry.courses?.filterByDate(entry.date), !courses.isEmpty else {
            return nil
        }

        return courses.entries(for: entry.weekday).count
    }

    var showCourseCountInSmall: Bool {
        return entry.courses?.filterByDate(entry.date).entries(for: entry.weekday).contains(where: {
            entry.time < $0.meetingTime.endTime
        }) ?? false
    }

    var body: some View {
        Group {
            switch widgetFamily {
            case .systemLarge:
                VStack {
                    Text("\(entry.date, formatter: CoursesDayWidgetView.dateFormatter)")
                        .fontWeight(.medium)
                    if let courseCount {
                        Text("\(courseCount) today").font(.subheadline).foregroundColor(.secondary)
                    }
                    CoursesDayWidgetSchedule(entry: entry)
                }.padding([.horizontal, .top])
            case .systemMedium:
                HStack(alignment: .top) {
                    VStack {
                        Text("\(entry.date, formatter: CoursesDayWidgetView.dayOfWeekFormatter)")
                            .fontWeight(.medium)
                            .textCase(.uppercase)
                        Text("\(entry.date, formatter: CoursesDayWidgetView.dateNumberFormatter)")
                            .font(.largeTitle)
                        if let courseCount {
                            Spacer()
                            Group {
                                Text("\(courseCount)").fontWeight(.medium).font(.title2)
                                Text("Today").font(.caption).textCase(.uppercase)
                            }.foregroundColor(.secondary)
                        }
                    }.frame(minWidth: 50, alignment: .leading).padding(.vertical)
                    CoursesDayWidgetSchedule(entry: entry)
                }.padding(.horizontal)
            case .systemSmall:
                let schedule = CoursesDayWidgetSchedule(entry: entry).padding(.horizontal, 8)
                if let courseCount, showCourseCountInSmall {
                    schedule
                    .mask(alignment: .bottom) {
                        LinearGradient(colors: [.black.opacity(0.1), .black], startPoint: UnitPoint(x: 0.5, y: 1.0), endPoint: UnitPoint(x: 0.5, y: 0.6))
                    }
                    .overlay(alignment: .bottom) {
                        Text("\(courseCount) today").fontWeight(.medium).padding(.bottom, 8)
                    }
                } else {
                    schedule
                }
            default:
                Text("Unsupported")
            }
        }
        .background(entry.configuration.background)
    }
}

struct CoursesDayWidget: Widget {
    var body: some WidgetConfiguration {
        let provider = IntentCoursesProvider<ConfigureCoursesDayWidgetIntent>(placeholderConfiguration: .init(background: .unknown))
        return IntentConfiguration(kind: WidgetKind.coursesDay,
                            intent: ConfigureCoursesDayWidgetIntent.self,
                            provider: provider) { entry in
            CoursesDayWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's Classes")
        .description("Your upcoming classes for the day, at a glance.")
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
            let configuration = ConfigureCoursesDayWidgetIntent.Configuration(background: .whiteGray)
            CoursesDayWidgetView(entry: CoursesEntry(date: Course.calendar.startOfDay(for: Date()), courses: dummyCourses, configuration: configuration))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Dummy courses")
            CoursesDayWidgetView(entry: CoursesEntry(date: Date(), courses: [
                Course(crn: "234234", code: "sdf", title: "sdf", section: "sdf", instructors: [], startDate: .distantPast, endDate: .distantFuture)
            ], configuration: configuration))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("No courses")
            CoursesDayWidgetView(entry: CoursesEntry(date: Date(), courses: nil, configuration: configuration))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Prompt to open")
        }
    }
}
