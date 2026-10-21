//
//  GetArchivedPolls.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Polls {
    struct GetArchivedPolls: PennMobileEndpoint {
        public typealias Response = [PollQuestion]
        public let path = "/portal/votes/recent/"
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?
        public let responseDecoder: JSONDecoder? = JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601)

        public init() async {
            let idHash = await PennMobileApplication.Polls.getPollsNetworkManagerId()
            self.bodyJSON = ["id_hash": idHash]
        }

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Unable to load past polls.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading past polls right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
