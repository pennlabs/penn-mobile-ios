//
//  CreateSublet.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Subletting {
    struct CreateSublet: PennMobileEndpoint {
        public typealias Response = Sublet
        public let path = "/sublet/properties/"
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let requestBodyEncoder: JSONEncoder? = .snakeCaseISO8601
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init(data: SubletData) {
            self.bodyJSON = data
        }

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Your sublet listing could not be created because some details may be missing or invalid.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Mobile is having trouble creating sublet listings right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
