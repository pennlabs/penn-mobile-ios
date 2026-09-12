//
//  UpdateSublet.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Subletting {
    struct UpdateSublet: PennMobileEndpoint {
        public typealias Response = Sublet
        public let path: String
        public let method = "PATCH"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let requestBodyEncoder: JSONEncoder? = .snakeCaseISO8601
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init(id: Int, data: SubletData) {
            self.path = "/sublet/properties/\(id)/"
            self.bodyJSON = data
        }
    }
}
