//
//  GetAccount.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/30/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Accounts {
    struct GetAccount: PennMobileEndpoint {
        public typealias Response = Account
        public let backend: EndpointBackend = .platform
        public let path = "/accounts/me/"
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = .snakeCase
        public let method: EndpointRequestMethod = .get(cacheAge: EndpointRequestMethod.defaultCacheAge)

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load your account.")
            case .serverError:
                ToastConfiguration(message: "Penn Labs is having trouble loading your account right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
