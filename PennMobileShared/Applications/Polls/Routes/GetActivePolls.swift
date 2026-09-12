//
//  GetActivePolls.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Polls {
    struct GetActivePolls: PennMobileEndpoint {
        public typealias Response = [PollQuestion]
        public let path = "/portal/polls/browse/"
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let responseDecoder: JSONDecoder? = JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601)

        public init(idHash: String) {
            self.bodyJSON = ["id_hash": idHash]
        }
    }
}
