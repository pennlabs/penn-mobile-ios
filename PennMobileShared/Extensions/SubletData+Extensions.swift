//
//  SubletData+Extensions.swift
//  PennMobile
//
//  Created by Anthony Li on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

public extension SubletData {
    init() {
        amenities = []
        title = ""
        address = ""
        externalLink = ""
        price = 0
        negotiable = false
        expiresAt = Date()
        startDate = Day()
        endDate = Day()
    }
}
