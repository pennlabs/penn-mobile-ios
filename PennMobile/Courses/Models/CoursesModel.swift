//
//  CourseModel.swift
//  PennMobile
//
//  Created by Anthony Li on 9/30/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

/// Manages the fetching of courses.
class CoursesModel: ObservableObject {
    static let shared = CoursesModel()

    private static let cacheFileName = "coursesCache"

    private func fetchCoursesFromNetwork() async throws -> [Course] {
        let courseData = try await PathAtPennNetworkManager.instance.fetchStudentCourses()
        return courseData.map { Course($0) }
    }

    /// Result of the last fetch. nil if unfetched.
    @Published var coursesResult: Result<[Course], Error>?

    /// Fetches courses from the cache or from the network, and stores the result into ``coursesResult``.
    /// - Parameter forceNetwork: Whether to force a refresh from the network.
    /// - Returns: List of fetched courses.
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
