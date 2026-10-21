//
//  RevokeShareCode.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.GSR {
    struct RevokeShareCode: PennMobileEndpoint {
        public typealias Response = GSRReservation
        public let path: String
        public let method = "DELETE"
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601)

        public init(shareCode: String) {
            self.path = "/gsr/share/\(shareCode)"
        }

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "This share link could not be revoked because it may no longer exist.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble revoking share links right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
