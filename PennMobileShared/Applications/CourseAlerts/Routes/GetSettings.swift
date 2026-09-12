//
//  GetSettings.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.CourseAlerts {
    struct GetSettings: PennMobileEndpoint {
        public typealias Response = CourseAlertSettings
        public let backend: EndpointBackend = .pennCourseAlert
        public let path = "/accounts/me/"
        public let authenticated = true

        public init() {}
    }
}
