//
//  GSRTimeSlot.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

struct GSRTimeSlot: Codable, Equatable {
    let startTime: Date
    let endTime: Date
    var isAvailable: Bool = true
    
    enum CodingKeys: CodingKey {
        case startTime
        case endTime
    }
}
