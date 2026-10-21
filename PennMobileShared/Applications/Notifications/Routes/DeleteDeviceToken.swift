//
//  DeleteDeviceToken.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Notifications {
    struct DeleteDeviceToken: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path: String
        public let method = "DELETE"

        public init(token: Data) {
            self.path = "/user/notifications/tokens/ios/\(token.hexString)/"
        }

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to unregister this device from notifications.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble unregistering this device from notifications right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
