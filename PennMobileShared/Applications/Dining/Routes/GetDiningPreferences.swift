//
//  GetDiningPreferences.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Dining {
    struct GetDiningPreferences: PennMobileEndpoint {
        public typealias Response = DiningPreferences
        public let path = "/dining/preferences/"
        public let authenticated = true

        public init() {}
    }
}
