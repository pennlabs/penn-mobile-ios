//
//  MakeOffer.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Subletting {
    struct MakeOffer: PennMobileEndpoint {
        public typealias Response = SubletOffer
        public let path: String
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let requestBodyEncoder: JSONEncoder? = .snakeCaseISO8601
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init(subletId: Int, data: SubletOfferData) {
            self.path = "/sublet/properties/\(subletId)/offers/"
            self.bodyJSON = data
        }

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Your offer could not be submitted because some details may be invalid.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble submitting offers right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
