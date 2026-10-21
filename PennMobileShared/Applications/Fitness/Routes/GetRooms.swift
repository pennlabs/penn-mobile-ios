//
//  GetRooms.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Fitness {
    struct GetRooms: PennMobileEndpoint {
        public typealias Response = [FitnessRoom]
        public let path = "/penndata/fitness/rooms/"
        public let responseDecoder: JSONDecoder? = .formatted("yyyy-MM-dd'T'HH:mm:ssZZZZZ")

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load fitness centers.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading fitness centers right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
