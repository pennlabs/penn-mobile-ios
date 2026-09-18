//
//  GetSublets.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Subletting {
    struct GetSublets: PennMobileEndpoint {
        public typealias Response = [Sublet]
        public let path = "/sublet/properties/"
        public let authenticated = true
        public let queryParams: [String: String]?
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init(queryParams: [String: String]? = nil) {
            self.queryParams = queryParams
        }

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Unable to load sublets matching these filters.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Mobile is having trouble loading sublets right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
