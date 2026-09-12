//
//  GetEvents.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Events {
    struct GetEvents: PennMobileEndpoint {
        public typealias Response = [PennEvent]
        public let path = "/penndata/events/"

        public init() {}
    }
}
