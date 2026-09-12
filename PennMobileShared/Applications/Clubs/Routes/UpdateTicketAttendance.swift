//
//  UpdateTicketAttendance.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Clubs {
    struct UpdateTicketAttendance: PennMobileEndpoint {
        public typealias Response = Ticket
        public let backend: EndpointBackend = .pennClubs
        public let path: String
        public let method = "PATCH"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let responseDecoder: JSONDecoder? = JSONDecoder(keyDecodingStrategy: .useDefaultKeys, dateDecodingStrategy: .iso8601)

        public init(id: String, attended: Bool) {
            self.path = "/tickets/\(id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id)/"
            self.bodyJSON = ["attended": attended]
        }
    }
}
