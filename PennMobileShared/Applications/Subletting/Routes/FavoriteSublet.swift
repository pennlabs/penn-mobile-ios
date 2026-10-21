//
//  FavoriteSublet.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Subletting {
    struct FavoriteSublet: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path: String
        public let method = "POST"
        public let authenticated = true

        public init(id: Int) {
            self.path = "/sublet/properties/\(id)/favorites/"
        }

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to add this sublet to your favorites.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble updating your favorite sublets right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
