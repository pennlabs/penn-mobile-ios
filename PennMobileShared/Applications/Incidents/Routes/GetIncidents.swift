//
//  GetIncidents.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Incidents {
    struct GetIncidents: PennMobileEndpoint {
        public typealias Response = [Incident]
        public let backend: EndpointBackend = .pennLabsStatus
        public let path = "/incidents.json"
        public let responseDecoder: JSONDecoder? = JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601)

        public init() {}

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Unable to load Penn Labs service status.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "The Penn Labs status page is having trouble loading right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
