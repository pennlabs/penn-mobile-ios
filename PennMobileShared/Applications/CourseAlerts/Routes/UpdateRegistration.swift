//
//  UpdateRegistration.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.CourseAlerts {
    struct UpdateRegistration: PennMobileEndpoint {
        struct Body: Encodable, Sendable {
            let deleted: Bool?
            let auto_resubscribe: Bool?
            let cancelled: Bool?
            let resubscribe: Bool?
        }
        
        public typealias Response = EmptyResponse
        public let backend: EndpointBackend = .pennCourseAlert
        public let path: String
        public let method = "PUT"
        public let authenticated = true
        public let headers: [String: String]?
        public let bodyJSON: (any Encodable & Sendable)?

        public init(id: String, deleted: Bool? = nil, autoResubscribe: Bool? = nil, cancelled: Bool? = nil, resubscribe: Bool? = nil, csrfToken: String) {
            self.path = "/api/alert/registrations/\(id)/"
            self.headers = PennMobileApplication.CourseAlerts.csrfHeaders(csrfToken)
            self.bodyJSON = Body(deleted: deleted, auto_resubscribe: autoResubscribe, cancelled: cancelled, resubscribe: resubscribe)
        }
    }
}
