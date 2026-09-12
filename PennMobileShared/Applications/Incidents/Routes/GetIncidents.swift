//
//  GetIncidents.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Incidents {
    struct GetIncidents: PennMobileEndpoint {
        public typealias Response = [Incident]
        public let backend: EndpointBackend = .pennLabsStatus
        public let path = "/incidents.json"
        public let responseDecoder: JSONDecoder? = JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601)

        public init() {}
    }
}
