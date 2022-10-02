//
//  CoursesView.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

private let colors: [Color] = [.redLight, .orangeLight, .yellowLight, .greenLight, .blueLight, .purpleLight]

/// View for the weekly schedule, assuming courses have been loaded.
struct WeekView: View {
    var courses: [Course]

    var body: some View {
        var codesToColors = [String: Color]()
        var colorsUsed = 0
        courses.sorted { $0.code < $1.code }.forEach {
            let color: Color
            if let theColor = codesToColors[$0.code] {
                color = theColor
            } else {
                color = colors[colorsUsed % colors.count]
                colorsUsed += 1
                codesToColors[$0.code] = color
            }
        }

        let entries = courses.flatMap { course in
            course.meetingTimes?.map {
                CourseScheduleEntry(course: course, meetingTime: $0, color: codesToColors[course.code]!)
            } ?? []
        }

        return ScrollView {
            LazyVStack {
                ForEach([2, 3, 4, 5, 6, 7, 1], id: \.self) { day in
                    CoursesDayView(day: day, entries: entries.filter { $0.meetingTime.weekday == day })
                }
            }.padding()
        }
    }
}

/// View for the Course Schedule page.
struct CoursesView: View {
    @EnvironmentObject var coursesModel: CoursesModel
    @State var date = Date()

    var body: some View {
        Group {
            switch coursesModel.coursesResult {
            case .none:
                ProgressView("Loading")
            case .some(.failure):
                VStack(spacing: 8) {
                    Text("Uh oh!").font(.largeTitle).fontWeight(.bold)
                    Text("We couldn't load your courses. Try again later.")
                }.foregroundColor(.red)
            case .some(.success(let courses)):
                WeekView(courses: courses.filter {
                    if let start = $0.startDate, let end = $0.endDate {
                        return start <= date && date <= end.addingTimeInterval(24 * 60 * 60)
                    } else {
                        return false
                    }
                })
            }
        }.task {
            _ = try? await coursesModel.fetchCourses()
        }.refreshable {
            _ = try? await coursesModel.fetchCourses(forceNetwork: true)
        }.navigationTitle("Course Schedule")
    }
}
