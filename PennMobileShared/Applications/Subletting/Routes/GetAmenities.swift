//
//  GetAmenities.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Subletting {
    struct GetAmenities: PennMobileEndpoint {
        public typealias Response = [String]
        public let path = "/sublet/amenities/"
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load sublet amenities.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading sublet amenities right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
