//
//  UpdateTicketAttendance.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Clubs {
    struct UpdateTicketAttendance: PennMobileEndpoint {
        public typealias Response = Ticket
        public let backend: EndpointBackend = .pennClubs
        public let path: String
        public let method = "PATCH"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let responseDecoder: JSONDecoder? = JSONDecoder(keyDecodingStrategy: .useDefaultKeys, dateDecodingStrategy: .iso8601)

        public init(id: String, attended: Bool) {
            self.path = "/tickets/\(id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id)/"
            self.bodyJSON = ["attended": attended]
        }

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "You don't have permission to update attendance for this ticket.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Clubs is having trouble updating ticket attendance right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
