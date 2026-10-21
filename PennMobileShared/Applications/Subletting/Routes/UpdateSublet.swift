//
//  UpdateSublet.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Subletting {
    struct UpdateSublet: PennMobileEndpoint {
        public typealias Response = Sublet
        public let path: String
        public let method = "PATCH"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let requestBodyEncoder: JSONEncoder? = .snakeCaseISO8601
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init(id: Int, data: SubletData) {
            self.path = "/sublet/properties/\(id)/"
            self.bodyJSON = data
        }

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Your sublet listing could not be updated because some details may be missing or invalid.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble updating sublet listings right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
