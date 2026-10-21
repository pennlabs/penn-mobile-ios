//
//  GetPollHistory.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Polls {
    struct GetPollHistory: PennMobileEndpoint {
        public typealias Response = [PollPost]
        public let path = "/portal/votes/all/"
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
                ToastConfiguration(message: "Unable to load your poll history.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble loading your poll history right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
