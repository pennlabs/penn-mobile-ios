//
//  GetAvailability.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.GSR {
    struct GetAvailability: PennMobileEndpoint {
        public typealias Response = GSRAvailabilityAPIResponse
        public let path: String
        public let authenticated = true
        public let queryParams: [String: String]?
        public let responseDecoder: JSONDecoder? = JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601)

        public init(location: GSRLocation, startDate: Date? = nil, endDate: Date? = nil) {
            let formatter = DateFormatter()
            formatter.locale = .enUS
            formatter.timeZone = .nyc
            formatter.dateFormat = "yyyy-MM-dd"
            
            var params = [String: String]()
            params["start"] = startDate.map { formatter.string(from: $0) }
            params["end"] = endDate.map { formatter.string(from: $0) }
            
            self.path = "/gsr/availability/\(location.lid)/\(location.gid)"
            self.queryParams = params
        }

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Unable to load room availability for this location.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Mobile is having trouble loading room availability right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
