//
//  GetMenus.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation

public extension PennMobileApplication.Dining {
    struct GetMenus: PennMobileEndpoint {
        public typealias Response = [DiningMenu]
        public let path: String
        public let responseDecoder: JSONDecoder? = .formatted("yyyy-MM-dd")

        public init(date: Date = Date()) {
            self.path = "/dining/menus/\(DateFormatter.yyyyMMdd.string(from: date))/"
        }
    }
}
