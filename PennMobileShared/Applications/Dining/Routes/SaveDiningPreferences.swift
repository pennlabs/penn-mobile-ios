//
//  SaveDiningPreferences.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Dining {
    struct SaveDiningPreferences: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path = "/dining/preferences/"
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?

        public init(venueIds: [Int]) {
            self.bodyJSON = ["venues": venueIds]
        }
    }
}
