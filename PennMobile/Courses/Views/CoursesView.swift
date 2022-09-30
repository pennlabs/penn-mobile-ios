//
//  CoursesView.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import SwiftUI

struct CoursesView: View {
    @EnvironmentObject var coursesModel: CoursesModel

    var body: some View {
        Group {
            switch coursesModel.coursesResult {
            case .none:
                ProgressView("Loading")
            case .some(.failure):
                VStack {
                    Text("Uh oh!").font(.largeTitle).fontWeight(.bold)
                    Text("We couldn't load your courses. Try again later.")
                }.foregroundColor(.red)
            case .some(.success(let courses)):
                List(courses) { course in
                    Text("\(course.code): \(course.title) (\(course.crn))")
                }
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
