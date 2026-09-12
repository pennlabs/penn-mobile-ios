//
//  DeleteDeviceToken.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Notifications {
    struct DeleteDeviceToken: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path: String
        public let method = "DELETE"

        public init(token: Data) {
            self.path = "/user/notifications/tokens/ios/\(token.hexString)/"
        }
    }
}
