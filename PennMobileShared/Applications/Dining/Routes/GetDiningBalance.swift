//
//  GetDiningBalance.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Dining {
    struct GetDiningBalance: PennMobileEndpoint {
        public typealias Response = DiningBalance
        public let backend: EndpointBackend = .campusExpress
        public let path = "/dining/currentBalance"
        public let headers: [String: String]?
        public let responseDecoder: JSONDecoder? = .snakeCase

        public init(diningToken: String) {
            self.headers = ["x-authorization": diningToken]
        }
    }
}
