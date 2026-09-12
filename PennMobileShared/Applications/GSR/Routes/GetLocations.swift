//
//  GetLocations.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.GSR {
    struct GetLocations: PennMobileEndpoint {
        public typealias Response = [GSRLocation]
        public let path = "/gsr/user-locations/"
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = .snakeCase

        public init() {}
    }
}
