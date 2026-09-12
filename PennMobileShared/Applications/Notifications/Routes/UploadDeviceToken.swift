//
//  UploadDeviceToken.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

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
    }
}
