//
//  GetPosts.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/21/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Posts {
    struct GetPosts: PennMobileEndpoint {
        public typealias Response = [Post]
        public let path = "/portal/posts/browse/"
        public let authenticated = true
        public let responseDecoder: JSONDecoder? = JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601)

        public init() {}

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load posts.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading posts right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
