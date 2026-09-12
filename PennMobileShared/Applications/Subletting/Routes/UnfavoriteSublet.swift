//
//  UnfavoriteSublet.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Subletting {
    struct UnfavoriteSublet: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path: String
        public let method = "DELETE"
        public let authenticated = true

        public init(id: Int) {
            self.path = "/sublet/properties/\(id)/favorites/"
        }
    }
}
