//
//  DeleteSubletImage.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Subletting {
    struct DeleteSubletImage: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path: String
        public let method = "DELETE"
        public let authenticated = true

        public init(imageId: Int) {
            self.path = "/sublet/properties/images/\(imageId)/"
        }

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "This image could not be deleted because it may no longer exist.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble deleting sublet images right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
