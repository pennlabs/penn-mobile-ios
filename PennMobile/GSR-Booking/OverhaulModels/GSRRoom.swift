//
//  GSRRoom.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

public struct GSRRoom {
    var name: String
    var id: Int
    var imgUrl: String
    var capacity: Int
    var timeSlots: [GSRTimeSlot]
    
    init(name: String, id: Int, imgUrl: String, capacity: Int) {
        self.name = name
        self.id = id
        self.imgUrl = imgUrl
        self.capacity = capacity
        self.timeSlots = []
    }
    
    mutating func addTimeSlot(time: GSRTimeSlot) {
        timeSlots.append(time)
    }
    
    
    
}
