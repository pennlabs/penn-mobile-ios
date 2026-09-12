//
//  GetHallUsage.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Laundry {
    struct GetHallUsage: PennMobileEndpoint {
        public typealias Response = LaundryHallUsageResponse
        public let path: String
        public let responseDecoder: JSONDecoder? = .snakeCase

        public init(hallId: Int) {
            self.path = "/laundry/rooms/\(hallId)"
        }
    }
}
