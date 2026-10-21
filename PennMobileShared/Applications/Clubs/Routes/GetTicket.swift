//
//  GetTicket.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Clubs {
    struct GetTicket: PennMobileEndpoint {
        public typealias Response = Ticket
        public let backend: EndpointBackend = .pennClubs
        public let path: String
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = JSONDecoder(keyDecodingStrategy: .useDefaultKeys, dateDecodingStrategy: .iso8601)

        public init(id: String) {
            self.path = "/tickets/\(id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id)/"
        }

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "This ticket doesn't exist or you don't have access to it.")
            case .serverError:
                ToastConfiguration(message: "Penn Clubs is having trouble loading this ticket right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
