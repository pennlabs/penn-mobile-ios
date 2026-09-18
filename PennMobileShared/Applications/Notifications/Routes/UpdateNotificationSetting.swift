//
//  UpdateNotificationSetting.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

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

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Unable to update this notification setting.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Mobile is having trouble saving your notification settings right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
