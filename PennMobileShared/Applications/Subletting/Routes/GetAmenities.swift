//
//  GetAmenities.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Subletting {
    struct GetAmenities: PennMobileEndpoint {
        public typealias Response = [String]
        public let path = "/sublet/amenities/"
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init() {}
    }
}
