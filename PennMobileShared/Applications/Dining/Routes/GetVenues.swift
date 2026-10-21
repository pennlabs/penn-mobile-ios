//
//  GetVenues.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Dining {
    struct GetVenues: PennMobileEndpoint {
        public typealias Response = [DiningVenue]
        public let path = "/dining/venues/"
        public let responseDecoder: JSONDecoder? = .formatted("yyyy-MM-dd'T'HH:mm:ss")

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load dining halls.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading dining halls right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
