//
//  GetRegistrations.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.CourseAlerts {
    struct GetRegistrations: PennMobileEndpoint {
        public typealias Response = [CourseAlert]
        public let backend: EndpointBackend = .pennCourseAlert
        public let path = "/api/alert/registrations/"
        public let authenticated = true

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load your course alerts.")
            case .serverError:
                ToastConfiguration(message: "Penn Course Alert is having trouble loading your alerts right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
