//
//  SaveDiningPreferences.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Dining {
    struct SaveDiningPreferences: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path = "/dining/preferences/"
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?

        public init(venueIds: [Int]) {
            self.bodyJSON = ["venues": venueIds]
        }

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to save your favorite dining halls.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble saving your favorite dining halls right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
