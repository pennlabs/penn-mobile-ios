//
//  GetMenus.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Dining {
    struct GetMenus: PennMobileEndpoint {
        public typealias Response = [DiningMenu]
        public let path: String
        public let responseDecoder: JSONDecoder? = .formatted("yyyy-MM-dd")

        public init(date: Date = Date()) {
            self.path = "/dining/menus/\(DateFormatter.yyyyMMdd.string(from: date))/"
        }

        public func errorResponse(error: BackendError) -> PennMobileBackendErrorHandler {
            switch error {
            case .clientError:
                PennMobileBackendErrorHandler(color: .red, message: "Dining menus aren't available for this date.")
            case .serverError:
                PennMobileBackendErrorHandler(color: .red, message: "Penn Mobile is having trouble loading dining menus right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
