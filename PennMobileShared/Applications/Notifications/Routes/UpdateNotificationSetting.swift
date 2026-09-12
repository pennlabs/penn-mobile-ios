//
//  UpdateNotificationSetting.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Notifications {
    struct UpdateNotificationSetting: PennMobileEndpoint {
        struct Body: Encodable, Sendable {
            let service: String
            let enabled: Bool
        }
        
        public typealias Response = EmptyResponse
        public let path: String
        public let method = "PATCH"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?

        public init(id: Int, service: String, enabled: Bool) {
            self.path = "/user/notifications/settings/\(id)/"
            self.bodyJSON = Body(service: service, enabled: enabled)
        }
    }
}
