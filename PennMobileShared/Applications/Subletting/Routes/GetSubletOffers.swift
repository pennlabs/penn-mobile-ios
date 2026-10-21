//
//  GetSubletOffers.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Subletting {
    struct GetSubletOffers: PennMobileEndpoint {
        public typealias Response = [SubletOffer]
        public let path: String
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init(subletId: Int) {
            self.path = "/sublet/properties/\(subletId)/offers/"
        }

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load offers for this sublet.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading sublet offers right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
