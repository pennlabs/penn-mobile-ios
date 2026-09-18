//
//  UnfavoriteSublet.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Subletting {
    struct UnfavoriteSublet: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path: String
        public let method = "DELETE"
        public let authenticated = true

        public init(id: Int) {
            self.path = "/sublet/properties/\(id)/favorites/"
        }

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Unable to remove this sublet from your favorites.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Mobile is having trouble updating your favorite sublets right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
