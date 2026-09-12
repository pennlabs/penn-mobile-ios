//
//  MakeOffer.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Subletting {
    struct MakeOffer: PennMobileEndpoint {
        public typealias Response = SubletOffer
        public let path: String
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let requestBodyEncoder: JSONEncoder? = .snakeCaseISO8601
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init(subletId: Int, data: SubletOfferData) {
            self.path = "/sublet/properties/\(subletId)/offers/"
            self.bodyJSON = data
        }
    }
}
