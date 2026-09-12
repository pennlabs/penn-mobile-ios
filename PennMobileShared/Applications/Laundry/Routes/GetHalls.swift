//
//  GetHalls.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Laundry {
    struct GetHalls: PennMobileEndpoint {
        public typealias Response = [LaundryHallInfo]
        public let path = "/laundry/halls/ids"
        public let responseDecoder: JSONDecoder? = .snakeCase

        public init() {}
    }
}
