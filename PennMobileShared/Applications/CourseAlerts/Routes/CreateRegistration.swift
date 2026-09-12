//
//  CreateRegistration.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.CourseAlerts {
    struct CreateRegistration: PennMobileEndpoint {
        struct Body: Encodable, Sendable {
            let section: String
            let auto_resubscribe: Bool
        }
        
        public typealias Response = CourseAlertMessage
        public let backend: EndpointBackend = .pennCourseAlert
        public let path = "/api/alert/registrations/"
        public let method = "POST"
        public let authenticated = true
        public let headers: [String: String]?
        public let bodyJSON: (any Encodable & Sendable)?

        public init(section: String, autoResubscribe: Bool, csrfToken: String) {
            self.headers = PennMobileApplication.CourseAlerts.csrfHeaders(csrfToken)
            self.bodyJSON = Body(section: section, auto_resubscribe: autoResubscribe)
        }
    }
}
