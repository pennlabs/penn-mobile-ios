//
//  GetFitnessPreferences.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Fitness {
    struct GetFitnessPreferences: PennMobileEndpoint {
        public typealias Response = FitnessPreferences
        public let path = "/fitness/preferences/"
        public let authenticated = true

        public init() {}
    }
}
