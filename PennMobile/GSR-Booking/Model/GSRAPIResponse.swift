//
//  GSRAPIResponse.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 4/9/2021.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import Foundation

struct GSRAvailabilityAPIResponse: Codable {
    let name: String
    let gid: Int
    let rooms: [GSRRoom]

    enum CodingKeys: CodingKey {
        case name
        case gid
        case rooms
    }
}
