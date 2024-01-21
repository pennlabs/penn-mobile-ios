//
//  CoursesView.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

/// View for the weekly schedule, assuming courses have been loaded.
struct WeekView: View {
    var courses: [Course]

    var body: some View {
        let entries = zip(courses, courses.computeColorAssignments()).flatMap {
            let (course, color) = $0
            return course.meetingTimes?.map {
                CourseScheduleEntry(course: course, meetingTime: $0, color: color)
            } ?? []
        }

        return ScrollView {
            VStack {
                ForEach([2, 3, 4, 5, 6, 7, 1], id: \.self) { day in
                    CoursesDayView(day: day, entries: entries.filter { $0.meetingTime.weekday == day })
                }
            }.padding()
        }
    }
}

/// View for the Course Schedule page.
struct CoursesView: View {
    @EnvironmentObject var coursesViewModel: CoursesViewModel
    @State var date = Date()
    @State var isPresentingLoginSheet = false

    var body: some View {
        Group {
            switch coursesViewModel.coursesResult {
            case .none:
                ProgressView("Loading")
            case .some(.failure(let error)):
                VStack(spacing: 8) {
                    Text("Uh oh!").font(.largeTitle).fontWeight(.bold)
                    Text("We couldn't load your courses. Try logging out and logging back in.")
                }
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
                .padding()
                .onAppear {
                    if case PathAtPennError.noTokenFound(_) = error {
                        isPresentingLoginSheet = true
                    }
                }
            case .some(.success(let courses)):
                WeekView(courses: courses.filterByDate(date))
            }
        }.task {
            _ = try? await coursesViewModel.fetchCourses()
        }.refreshable {
            _ = try? await coursesViewModel.fetchCourses(forceNetwork: true)
        }.sheet(isPresented: $isPresentingLoginSheet) {
            LabsLoginView { success in
                if success {
                    coursesViewModel.coursesResult = nil
                    Task {
                        try? await coursesViewModel.fetchCourses(forceNetwork: true)
                    }
                }
            }
        }.navigationTitle("Course Schedule")
    }
}
