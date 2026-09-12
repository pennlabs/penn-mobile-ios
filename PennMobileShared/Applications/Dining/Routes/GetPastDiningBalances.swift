//
//  GetPastDiningBalances.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Dining {
    struct GetPastDiningBalances: PennMobileEndpoint {
        public typealias Response = PastDiningBalances
        public let backend: EndpointBackend = .campusExpress
        public let path = "/dining/pastBalances"
        public let headers: [String: String]?
        public let queryParams: [String: String]?
        public let responseDecoder: JSONDecoder? = .snakeCase

        public init(diningToken: String, startDate: String, endDate: String) {
            self.headers = ["x-authorization": diningToken]
            self.queryParams = ["start_date": startDate, "end_date": endDate]
        }
    }
}
