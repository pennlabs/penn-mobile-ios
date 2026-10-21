//
//  AnswerPoll.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

public extension PennMobileApplication.Polls {
    struct AnswerPoll: PennMobileEndpoint {
        struct Body: Encodable, Sendable {
            let id_hash: String
            let poll_options: [Int]
        }
        
        public typealias Response = EmptyResponse
        public let path = "/portal/votes/"
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?

        public init(optionId: Int) async {
            let idHash = await PennMobileApplication.Polls.getPollsNetworkManagerId()
            self.bodyJSON = Body(id_hash: idHash, poll_options: [optionId])
        }
        public init(idHash: String, optionId: Int) {
            self.bodyJSON = Body(id_hash: idHash, poll_options: [optionId])
        }

        public func errorResponse(error: BackendError) -> ToastConfiguration {
            switch error {
            case .clientError:
                ToastConfiguration(message: "Your vote could not be submitted because this poll may have closed or you may have already voted.")
            case .serverError:
                ToastConfiguration(message: "Penn Mobile is having trouble submitting votes right now.")
            case .platformError, .decodingError, .unknownResponseError, .otherError:
                .standard(for: error)
            }
        }
    }
}
