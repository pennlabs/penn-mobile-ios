//
//  GetClubEvents.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Events {
    struct GetClubEvents: PennMobileEndpoint {
        public typealias Response = [PennEvent]
        public let backend: EndpointBackend = .pennClubs
        public let path = "/events/"

        public init() {}
    }
}
