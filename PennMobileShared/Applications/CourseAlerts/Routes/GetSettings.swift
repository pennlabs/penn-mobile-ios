//
//  GetSettings.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.CourseAlerts {
    struct GetSettings: PennMobileEndpoint {
        public typealias Response = CourseAlertSettings
        public let backend: EndpointBackend = .pennCourseAlert
        public let path = "/accounts/me/"
        public let authenticated = true

        public init() {}

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Unable to load your Penn Course Alert settings.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Course Alert is having trouble loading your settings right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
