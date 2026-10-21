//
//  GetNotificationSettings.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Notifications {
    struct GetNotificationSettings: PennMobileEndpoint {
        public typealias Response = [NotificationSetting]
        public let path = "/user/notifications/settings/"
        public let authenticated = true

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load your notification settings.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading your notification settings right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
