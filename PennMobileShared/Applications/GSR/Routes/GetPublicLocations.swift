//
//  GetPublicLocations.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.GSR {
    struct GetPublicLocations: PennMobileEndpoint {
        public typealias Response = [GSRLocation]
        public let path = "/gsr/locations/"
        public let responseDecoder: JSONDecoder? = .snakeCase

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load study room locations.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading study room locations right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
