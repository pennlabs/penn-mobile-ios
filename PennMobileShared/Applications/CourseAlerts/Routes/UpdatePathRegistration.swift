//
//  UpdatePathRegistration.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.CourseAlerts {
    struct UpdatePathRegistration: PennMobileEndpoint {
        struct Body: Encodable, Sendable {
            struct Section: Encodable, Sendable {
                let id: String
            }
            let semester: String
            let sections: [Section]
        }
        
        public typealias Response = EmptyResponse
        public let backend: EndpointBackend = .pennCoursePlan
        public let path = "/plan/schedules/path/"
        public let method = "PUT"
        public let authenticated = true
        public let headers: [String: String]?
        public let bodyJSON: (any Encodable & Sendable)?

        public init(srcdb: String, crns: [String], csrfToken: String) {
            self.headers = PennMobileApplication.CourseAlerts.csrfHeaders(csrfToken)
            self.bodyJSON = Body(semester: srcdb, sections: crns.map { Body.Section(id: $0) })
        }

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Unable to update your Penn Course Plan schedule with these sections.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Course Plan is having trouble updating your schedule right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
