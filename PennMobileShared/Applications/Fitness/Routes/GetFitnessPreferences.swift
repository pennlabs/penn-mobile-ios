//
//  GetFitnessPreferences.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Fitness {
    struct GetFitnessPreferences: PennMobileEndpoint {
        public typealias Response = FitnessPreferences
        public let path = "/fitness/preferences/"
        public let authenticated = true

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load your favorite fitness centers.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading your favorite fitness centers right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
