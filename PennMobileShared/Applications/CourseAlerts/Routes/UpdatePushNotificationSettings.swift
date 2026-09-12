//
//  UpdatePushNotificationSettings.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.CourseAlerts {
    struct UpdatePushNotificationSettings: PennMobileEndpoint {
        struct Body: Encodable, Sendable {
            struct Profile: Encodable, Sendable {
                let push_notifications: Bool
            }
            let profile: Profile
        }
        
        public typealias Response = EmptyResponse
        public let backend: EndpointBackend = .pennCourseAlert
        public let path = "/accounts/me/"
        public let method = "PATCH"
        public let authenticated = true
        public let headers: [String: String]?
        public let bodyJSON: (any Encodable & Sendable)?

        public init(pushNotifications: Bool, csrfToken: String) {
            self.headers = PennMobileApplication.CourseAlerts.csrfHeaders(csrfToken)
            self.bodyJSON = Body(profile: .init(push_notifications: pushNotifications))
        }
    }
}
