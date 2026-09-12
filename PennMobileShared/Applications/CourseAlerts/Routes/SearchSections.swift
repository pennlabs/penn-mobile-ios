//
//  SearchSections.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.CourseAlerts {
    struct SearchSections: PennMobileEndpoint {
        public typealias Response = [CourseSection]
        public let backend: EndpointBackend = .pennCourseAlert
        public let path: String
        public let queryParams: [String: String]?

        public init(searchText: String, date: Date = Date()) {
            let year = Calendar.current.component(.year, from: date)
            let month = Calendar.current.component(.month, from: date)
            let semester = month < 5 ? "A" : month < 9 ? "B" : "C"
            
            self.path = "/api/base/\(year)\(semester)/search/sections/"
            self.queryParams = ["search": searchText]
        }
    }
}
