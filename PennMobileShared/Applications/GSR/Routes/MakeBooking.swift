//
//  MakeBooking.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.GSR {
    struct MakeBooking: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path = "/gsr/book/"
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let requestBodyEncoder: JSONEncoder? = {
            let formatter = DateFormatter()
            formatter.locale = .enUS
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .formatted(formatter)
            return encoder
        }()

        public init(booking: GSRBooking) {
            self.bodyJSON = booking
        }

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "This room could not be booked because it may no longer be available or you may have reached your booking limit.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Mobile is having trouble booking rooms right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
