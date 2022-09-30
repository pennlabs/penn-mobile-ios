//
//  CourseModel.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

class CoursesModel: ObservableObject {
    static let shared = CoursesModel()

    private static let cacheFileName = "coursesCache"

    private func fetchCoursesFromNetwork() async throws -> [Course] {
        let courseData = try await PathAtPennNetworkManager.instance.fetchCourses()
        return courseData.map { Course($0) }
    }

    @Published var coursesResult: Result<[Course], Error>?

    func fetchCourses(forceNetwork: Bool = false) async throws -> [Course] {
        if let courses = try? coursesResult?.get(), !forceNetwork {
            return courses
        }

        if !forceNetwork && Storage.fileExists(CoursesModel.cacheFileName, in: .caches) {
            let courses = Storage.retrieve(CoursesModel.cacheFileName, from: .caches, as: [Course].self)
            coursesResult = .success(courses)
            return courses
        }

        do {
            let courses = try await fetchCoursesFromNetwork()
            coursesResult = .success(courses)
            Storage.store(courses, to: .caches, as: CoursesModel.cacheFileName)
            return courses
        } catch let error {
            coursesResult = .failure(error)
            throw error
        }
    }
}
