//
//  GetSubletOffers.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Subletting {
    struct GetSubletOffers: PennMobileEndpoint {
        public typealias Response = [SubletOffer]
        public let path: String
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init(subletId: Int) {
            self.path = "/sublet/properties/\(subletId)/offers/"
        }
    }
}
