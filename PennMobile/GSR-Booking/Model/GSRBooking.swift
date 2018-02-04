//
//  GSRBooking.swift
//  PennMobile
//
//  Created by Josh Doman on 2/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class GSRBooking {
    let locationId: Int
    let roomId: Int
    let start: Date
    let end: Date
    var user: GSRUser! = nil
    var groupName = "Penn Mobile Booking"
    
    init(locationId: Int, roomId: Int, start: Date, end: Date) {
        self.locationId = locationId
        self.roomId = roomId
        self.start = start
        self.end = end
    }
}
