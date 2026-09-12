//
//  GetNotificationSettings.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Notifications {
    struct GetNotificationSettings: PennMobileEndpoint {
        public typealias Response = [NotificationSetting]
        public let path = "/user/notifications/settings/"
        public let authenticated = true

        public init() {}
    }
}
