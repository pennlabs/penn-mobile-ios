//
//  UpdatePathRegistration.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.CourseAlerts {
    struct UpdatePathRegistration: PennMobileEndpoint {
        struct Body: Encodable, Sendable {
            struct Section: Encodable, Sendable {
                let id: String
            }
            let semester: String
            let sections: [Section]
        }
        
        public typealias Response = EmptyResponse
        public let backend: EndpointBackend = .pennCoursePlan
        public let path = "/plan/schedules/path/"
        public let method = "PUT"
        public let authenticated = true
        public let headers: [String: String]?
        public let bodyJSON: (any Encodable & Sendable)?

        public init(srcdb: String, crns: [String], csrfToken: String) {
            self.headers = PennMobileApplication.CourseAlerts.csrfHeaders(csrfToken)
            self.bodyJSON = Body(semester: srcdb, sections: crns.map { Body.Section(id: $0) })
        }
    }
}
