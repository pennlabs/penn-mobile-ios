//
//  PathAtPennNetworkManager.swift
//  PennMobile
//
//  Created by Anthony Li on 9/25/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation
import SwiftSoup

enum PathAtPennError: Error {
    /// The data was a malformed string.
    case corruptString

    /// A token was not found in the Path@Penn authorization response.
    case noTokenFound

    /// The returned ``URLResponse`` was not an ``HTTPURLResponse``.
    case notHttpResponse

    /// The API returned an unexpected status code.
    case unexpectedStatus(Int)

    /// The student data was not returned from Path@Penn.
    case noStudentData
}

class PathAtPennNetworkManager {
    static let instance = PathAtPennNetworkManager()
}

// MARK: - Path@Penn Authentication

extension PathAtPennNetworkManager {
    static private let oauthURL = URL(string: "https://idp.pennkey.upenn.edu/idp/profile/oidc/authorize?response_type=code&scope=openid+email+profile&client_id=courses.upenn.edu%2Fsam_rMReby8Vl3M1BiyVWMAT&redirect_uri=https%3A%2F%2Fcourses.upenn.edu%2Fsam%2Fcodetotoken")!

    /// Fetches and returns a Path@Penn auth token.
    func getToken() async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: PathAtPennNetworkManager.oauthURL)
        let str = try String(data: data, encoding: .utf8).unwrap(orThrow: PathAtPennError.corruptString)
        let matches = str.getMatches(for: "value: \"(.*)\"")
        let token = try matches.first.unwrap(orThrow: PathAtPennError.noTokenFound)

        return token
    }
}

// MARK: - Student Data

extension PathAtPennNetworkManager {
    struct StudentData: Codable {
        var reg: [String: [String]]
    }

    struct CourseData: Codable {
        var code: String
        var no: String
        var title: String
        var meetingTimes: String
        var instr: String
    }

    static private let studentDataURL = URL(string: "https://courses.upenn.edu/api/?page=sisproxy&action=studentdata")!
    static private let courseSearchURL = URL(string: "https://courses.upenn.edu/api/?page=fose&route=search")!

    func fetchStudentData() async throws -> StudentData {
        let token = try await getToken()

        var request = URLRequest(url: PathAtPennNetworkManager.studentDataURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = String.getPostString(params: [
            "authtoken": token
        ]).data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw PathAtPennError.notHttpResponse
        }

        guard response.statusCode == 200 else {
            throw PathAtPennError.unexpectedStatus(response.statusCode)
        }

        let str = try String(data: data, encoding: .utf8).unwrap(orThrow: PathAtPennError.corruptString)
        let matches = str.getMatches(for: "^setRecord\\((.*)\\)$")
        let jsonString = try matches.first.unwrap(orThrow: PathAtPennError.noStudentData)
        let jsonData = try jsonString.data(using: .utf8).unwrap(orThrow: PathAtPennError.corruptString)

        return try JSONDecoder().decode(StudentData.self, from: jsonData)
    }

    func fetchCourses(srcdb: String, crns: [Int]) async throws -> [CourseData] {
        struct CourseRequest: Encodable {
            var other: Other
            var criteria: [Criteria]

            struct Other: Encodable {
                var srcdb: String
            }

            struct Criteria: Encodable {
                let field = "crn"
                var value: String
            }
        }

        let crnString = crns.map { String($0) }.joined(separator: ",")
        let requestInfo = CourseRequest(
            other: CourseRequest.Other(srcdb: srcdb),
            criteria: [CourseRequest.Criteria(value: crnString)])

        // Ah, the joys of URL-encoded JSON
        let requestData = try String(data: JSONEncoder().encode(requestInfo), encoding: .utf8).flatMap {
            $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }.flatMap {
            $0.data(using: .utf8)
        }.unwrap(orThrow: PathAtPennError.corruptString)

        var request = URLRequest(url: PathAtPennNetworkManager.courseSearchURL)
        request.httpMethod = "POST"
        request.httpBody = requestData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw PathAtPennError.notHttpResponse
        }

        guard response.statusCode == 200 else {
            throw PathAtPennError.unexpectedStatus(response.statusCode)
        }

        struct CourseSearchResults: Decodable {
            var results: [CourseData]
        }

        return try JSONDecoder().decode(CourseSearchResults.self, from: data).results
    }

    func fetchCourses() async throws -> [CourseData] {
        let reg = try await fetchStudentData().reg

        return try await withThrowingTaskGroup(of: [CourseData].self) { group in
            for (srcdb, descriptors) in reg {
                let crns = descriptors.compactMap {
                    $0.split(separator: "|").first
                }.compactMap {
                    Int($0)
                }

                group.addTask {
                    try await self.fetchCourses(srcdb: srcdb, crns: crns)
                }
            }

            return try await group.reduce(into: []) { $0 += $1 }
        }
    }
}
