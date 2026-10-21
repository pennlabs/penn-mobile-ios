//
//  GetHallUsage.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Laundry {
    struct GetHallUsage: PennMobileEndpoint {
        public typealias Response = LaundryHallUsageResponse
        public let path: String
        public let responseDecoder: JSONDecoder? = .snakeCase

        public init(hallId: Int) {
            self.path = "/laundry/rooms/\(hallId)"
        }

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Machine availability isn't available for this laundry room.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading laundry machine availability right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
