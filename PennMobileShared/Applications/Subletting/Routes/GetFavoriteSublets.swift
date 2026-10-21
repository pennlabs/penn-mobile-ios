//
//  GetFavoriteSublets.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Subletting {
    struct GetFavoriteSublets: PennMobileEndpoint {
        public typealias Response = [Sublet]
        public let path = "/sublet/favorites/"
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load your favorite sublets.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading your favorite sublets right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
