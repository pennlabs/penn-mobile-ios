//
//  GSRTimeSlot.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

public struct GSRTimeSlot {
    var isAvailable: Bool
    var startTime: Date
    var endTime: Date
    
    init(isAvailable: Bool, startTime:Date, endTime:Date) {
        self.isAvailable = isAvailable
        self.startTime = startTime
        self.endTime = endTime
    }
}
