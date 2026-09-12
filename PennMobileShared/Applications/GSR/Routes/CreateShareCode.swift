//
//  CreateShareCode.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.GSR {
    struct CreateShareCode: PennMobileEndpoint {
        public typealias Response = GSRShareCode
        public let path = "/gsr/share/"
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?

        public init(bookingId: String) {
            self.bodyJSON = ["booking_id": bookingId]
        }
    }
}
