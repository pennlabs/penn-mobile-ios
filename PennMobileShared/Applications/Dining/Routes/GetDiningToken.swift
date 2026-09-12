//
//  GetDiningToken.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

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
    }
}
