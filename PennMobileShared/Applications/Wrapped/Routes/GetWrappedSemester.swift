//
//  GetWrappedSemester.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Wrapped {
    struct GetWrappedSemester: PennMobileEndpoint {
        public typealias Response = WrappedModel
        public let path: String

        public init(semester: String) {
            self.path = "/wrapped/semester/\(semester)/"
        }

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Mobile Wrapped isn't available for this semester.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Mobile is having trouble loading your Wrapped right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
