//
//  GetSublets.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Subletting {
    struct GetSublets: PennMobileEndpoint {
        public typealias Response = [Sublet]
        public let path = "/sublet/properties/"
        public let authenticated = true
        public let queryParams: [String: String]?
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init(queryParams: [String: String]? = nil) {
            self.queryParams = queryParams
        }
    }
}
