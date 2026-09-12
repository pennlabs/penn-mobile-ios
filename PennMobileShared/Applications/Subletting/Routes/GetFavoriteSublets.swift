//
//  GetFavoriteSublets.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Subletting {
    struct GetFavoriteSublets: PennMobileEndpoint {
        public typealias Response = [Sublet]
        public let path = "/sublet/favorites/"
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init() {}
    }
}
