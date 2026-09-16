//
//  GetDiningToken.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Dining {
    struct GetDiningToken: PennMobileEndpoint {
        public typealias Response = DiningToken
        public let backend: EndpointBackend = .campusExpress
        public let path = "/oauth/token"
        public let queryParams: [String: String]?

        public init(clientId: String, code: String, codeVerifier: String, redirectUri: String) {
            self.queryParams = [
                "client_id": clientId,
                "code_verifier": codeVerifier,
                "grant_type": "authorization_code",
                "code": code,
                "redirect_uri": redirectUri
            ]
        }

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Your Campus Express sign-in could not be verified.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Campus Express is having trouble signing you in right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
