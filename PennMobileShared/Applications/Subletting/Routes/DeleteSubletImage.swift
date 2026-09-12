//
//  DeleteSubletImage.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Subletting {
    struct DeleteSubletImage: PennMobileEndpoint {
        public typealias Response = EmptyResponse
        public let path: String
        public let method = "DELETE"
        public let authenticated = true

        public init(imageId: Int) {
            self.path = "/sublet/properties/images/\(imageId)/"
        }
    }
}
