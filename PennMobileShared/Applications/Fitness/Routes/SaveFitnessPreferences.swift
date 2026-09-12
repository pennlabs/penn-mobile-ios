//
//  SaveFitnessPreferences.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Fitness {
    struct SaveFitnessPreferences: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path = "/fitness/preferences/"
        public let method = "POST"
        public let authenticated = true
        public let bodyJSON: (any Encodable & Sendable)?

        public init(roomIds: [Int]) {
            self.bodyJSON = FitnessPreferences(rooms: roomIds)
        }
    }
}
