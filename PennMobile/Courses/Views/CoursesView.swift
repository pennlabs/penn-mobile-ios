//
//  CoursesView.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct WeekView: View {
    var courses: [Course]

    var body: some View {
        let entries = courses.flatMap { course in course.meetingTimes?.map {
            CourseScheduleEntry(course: course, meetingTime: $0)
        } ?? [] }

        return ScrollView {
            LazyVStack {
                ForEach([2, 3, 4, 5, 6, 7, 1], id: \.self) { day in
                    CoursesDayView(day: day, entries: entries.filter { $0.meetingTime.weekday == day })
                }
            }.padding()
        }
    }
}

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
            Task {
                _ = try? await coursesModel.fetchCourses(forceNetwork: true)
            }
        }.navigationTitle("Course Schedule")
    }
}
