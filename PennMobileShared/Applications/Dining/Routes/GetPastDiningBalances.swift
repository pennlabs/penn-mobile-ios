//
//  GetPastDiningBalances.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

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

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Unable to load your dining balance history because your Campus Express session may have expired.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Campus Express is having trouble loading your balance history right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
