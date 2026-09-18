//
//  GetRoomUsage.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Fitness {
    struct GetRoomUsage: PennMobileEndpoint {
        public typealias Response = FitnessRoomData
        public let path: String
        public let queryParams: [String: String]?
        public let responseDecoder: JSONDecoder? = .formatted("yyyy-MM-dd")

        public init(roomId: Int, date: Date = Date(), numSamples: Int = 3, groupBy: String = "week", field: String = "count") {
            self.path = "/penndata/fitness/usage/\(roomId)/"
            self.queryParams = [
                "date": DateFormatter.yyyyMMdd.string(from: date),
                "num_samples": String(numSamples),
                "group_by": groupBy,
                "field": field
            ]
        }

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Usage data isn't available for this fitness center.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Mobile is having trouble loading fitness center usage right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
