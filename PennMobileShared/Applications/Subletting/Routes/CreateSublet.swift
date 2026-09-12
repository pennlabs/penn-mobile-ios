//
//  CreateSublet.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Subletting {
    struct CreateSublet: PennMobileEndpoint {
        public typealias Response = Sublet
        public let path = "/sublet/properties/"
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let requestBodyEncoder: JSONEncoder? = .snakeCaseISO8601
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init(data: SubletData) {
            self.bodyJSON = data
        }
    }
}
