//
//  GetEvents.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Events {
    struct GetEvents: PennMobileEndpoint {
        public typealias Response = [PennEvent]
        public let path = "/penndata/events/"

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load campus events.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading campus events right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
