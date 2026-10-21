//
//  GetSublet.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Subletting {
    struct GetSublet: PennMobileEndpoint {
        public typealias Response = Sublet
        public let path: String
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = .snakeCaseFlexibleDates

        public init(id: Int) {
            self.path = "/sublet/properties/\(id)/"
        }

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "This sublet doesn't exist or is no longer listed.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading this sublet right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
