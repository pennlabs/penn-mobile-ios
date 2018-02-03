//
//  GSRTimeSlot.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

public class GSRTimeSlot: NSObject {
    let roomId: Int
    let isAvailable: Bool
    let startTime: Date
    let endTime: Date
    
    weak var prev: GSRTimeSlot? = nil
    weak var next: GSRTimeSlot? = nil
    
    init(roomId: Int, isAvailable: Bool, startTime: Date, endTime: Date) {
        self.roomId = roomId
        self.isAvailable = isAvailable
        self.startTime = startTime
        self.endTime = endTime
    }
    
    static func ==(lhs: GSRTimeSlot, rhs: GSRTimeSlot) -> Bool {
        return lhs.roomId == rhs.roomId && lhs.isAvailable == rhs.isAvailable && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
    }
}
