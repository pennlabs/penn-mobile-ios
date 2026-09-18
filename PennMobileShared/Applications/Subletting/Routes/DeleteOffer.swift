//
//  DeleteOffer.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Subletting {
    struct DeleteOffer: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path: String
        public let method = "DELETE"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let requestBodyEncoder: JSONEncoder? = .snakeCaseISO8601

        public init(subletId: Int, data: SubletOfferData) {
            self.path = "/sublet/properties/\(subletId)/offers/"
            self.bodyJSON = data
        }

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "This offer could not be withdrawn because it may no longer exist.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Mobile is having trouble withdrawing offers right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
