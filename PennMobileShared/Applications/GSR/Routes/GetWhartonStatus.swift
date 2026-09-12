//
//  GetWhartonStatus.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.GSR {
    struct GetWhartonStatus: PennMobileEndpoint {
        public typealias Response = WhartonStatus
        public let path = "/gsr/wharton/"
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = .snakeCase

        public init() {}
    }
}
