//
//  DeleteOffer.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Subletting {
    struct DeleteOffer: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path: String
        public let method = "DELETE"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let requestBodyEncoder: JSONEncoder? = .snakeCaseISO8601

        public init(subletId: Int, data: SubletOfferData) {
            self.path = "/sublet/properties/\(subletId)/offers/"
            self.bodyJSON = data
        }
    }
}
