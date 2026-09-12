//
//  GetWrappedSemester.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Wrapped {
    struct GetWrappedSemester: PennMobileEndpoint {
        public typealias Response = WrappedModel
        public let path: String

        public init(semester: String) {
            self.path = "/wrapped/semester/\(semester)/"
        }
    }
}
