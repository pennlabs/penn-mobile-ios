//
//  UploadDeviceToken.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Notifications {
    struct UploadDeviceToken: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path: String
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?

        public init(token: Data, isDev: Bool) {
            self.path = "/user/notifications/tokens/ios/\(token.hexString)/"
            self.bodyJSON = ["is_dev": isDev]
        }

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Unable to register this device for notifications.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Mobile is having trouble registering this device for notifications right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
