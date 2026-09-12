//
//  GetRegistrations.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.CourseAlerts {
    struct GetRegistrations: PennMobileEndpoint {
        public typealias Response = [CourseAlert]
        public let backend: EndpointBackend = .pennCourseAlert
        public let path = "/api/alert/registrations/"
        public let authenticated = true

        public init() {}
    }
}
