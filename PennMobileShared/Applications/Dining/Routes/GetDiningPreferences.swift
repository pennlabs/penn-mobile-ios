//
//  GetDiningPreferences.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Dining {
    struct GetDiningPreferences: PennMobileEndpoint {
        public typealias Response = DiningPreferences
        public let path = "/dining/preferences/"
        public let authenticated = true

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load your favorite dining halls.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading your favorite dining halls right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
