//
//  GetWhartonStatus.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.GSR {
    struct GetWhartonStatus: PennMobileEndpoint {
        public typealias Response = WhartonStatus
        public let path = "/gsr/wharton/"
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = .snakeCase

        public init() {}

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Unable to check your Wharton eligibility.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Mobile is having trouble checking your Wharton eligibility right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
