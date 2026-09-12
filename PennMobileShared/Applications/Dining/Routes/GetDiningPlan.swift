//
//  GetDiningPlan.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Dining {
    struct GetDiningPlan: PennMobileEndpoint {
        public typealias Response = DiningPlan
        public let backend: EndpointBackend = .campusExpress
        public let path = "/dining/currentPlan"
        public let headers: [String: String]?
        public let responseDecoder: JSONDecoder? = .formatted("yyyy-MM-dd")

        public init(diningToken: String) {
            self.headers = ["x-authorization": diningToken]
        }
    }
}
