//
//  GSRRoom.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class GSRRoom {
    let name: String
    let id: Int
    let imageUrl: String?
    let capacity: Int
    let timeSlots: [GSRTimeSlot]
    
    init(name: String, id: Int, imageUrl: String?, capacity: Int, timeSlots: [GSRTimeSlot]) {
        self.name = name
        self.id = id
        self.imageUrl = imageUrl
        self.capacity = capacity
        self.timeSlots = timeSlots
    }
}
