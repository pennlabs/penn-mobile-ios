//
//  GetMajors.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/30/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Accounts {
    struct GetMajors: PennMobileEndpoint {
        public typealias Response = [Major]
        public let backend: EndpointBackend = .platform
        public let path = "/accounts/majors/"
        public let responseDecoder: JSONDecoder? = .snakeCase

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load majors.")
            case .serverError:
                ToastConfiguration(message: "Penn Labs is having trouble loading majors right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
