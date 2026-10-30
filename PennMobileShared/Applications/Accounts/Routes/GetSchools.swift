//
//  GetSchools.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/30/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Accounts {
    struct GetSchools: PennMobileEndpoint {
        public typealias Response = [School]
        public let backend: EndpointBackend = .platform
        public let path = "/accounts/schools/"
        public let responseDecoder: JSONDecoder? = .snakeCase

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load schools.")
            case .serverError:
                ToastConfiguration(message: "Penn Labs is having trouble loading schools right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
