//
//  GetDiningPlan.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

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

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Unable to load your dining plan because your Campus Express session may have expired.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Campus Express is having trouble loading your dining plan right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
