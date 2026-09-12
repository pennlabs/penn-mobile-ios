//
//  GetVenues.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Dining {
    struct GetVenues: PennMobileEndpoint {
        public typealias Response = [DiningVenue]
        public let path = "/dining/venues/"
        public let responseDecoder: JSONDecoder? = .formatted("yyyy-MM-dd'T'HH:mm:ss")

        public init() {}
    }
}
