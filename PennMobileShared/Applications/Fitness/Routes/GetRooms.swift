//
//  GetRooms.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Fitness {
    struct GetRooms: PennMobileEndpoint {
        public typealias Response = [FitnessRoom]
        public let path = "/penndata/fitness/rooms/"
        public let responseDecoder: JSONDecoder? = .formatted("yyyy-MM-dd'T'HH:mm:ssZZZZZ")

        public init() {}
    }
}
