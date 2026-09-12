//
//  RevokeShareCode.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.GSR {
    struct RevokeShareCode: PennMobileEndpoint {
        public typealias Response = GSRReservation
        public let path: String
        public let method = "DELETE"
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601)

        public init(shareCode: String) {
            self.path = "/gsr/share/\(shareCode)"
        }
    }
}
