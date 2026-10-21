//
//  GetHalls.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Laundry {
    struct GetHalls: PennMobileEndpoint {
        public typealias Response = [LaundryHallInfo]
        public let path = "/laundry/halls/ids"
        public let responseDecoder: JSONDecoder? = .snakeCase

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load laundry rooms.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading laundry rooms right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
