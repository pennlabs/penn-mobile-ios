//
//  GSRBooking.swift
//  PennMobile
//
//  Created by Josh Doman on 2/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class GSRBooking {
    let location: GSRLocation
    let roomId: Int
    let start: Date
    let end: Date
    var user: GSRUser! = nil
    var groupName = "Penn Mobile Booking"
    
    init(location: GSRLocation, roomId: Int, start: Date, end: Date) {
        self.location = location
        self.roomId = roomId
        self.start = start
        self.end = end
    }
}
