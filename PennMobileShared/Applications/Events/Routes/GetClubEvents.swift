//
//  GetClubEvents.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Events {
    struct GetClubEvents: PennMobileEndpoint {
        public typealias Response = [PennEvent]
        public let backend: EndpointBackend = .pennClubs
        public let path = "/events/"

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load club events.")
            case .serverError:
                ToastConfiguration(message: "Penn Clubs is having trouble loading events right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
