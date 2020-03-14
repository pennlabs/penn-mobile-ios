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
    var sessionId: String! = nil
    var groupName = "Penn Mobile Booking"
    var name: String?
    
    convenience init(location: GSRLocation, roomId: Int, start: Date, end: Date, name: String?) {
        self.init(location: location, roomId: roomId, start: start, end: end)
        self.name = name
    }
    
    init(location: GSRLocation, roomId: Int, start: Date, end: Date) {
        self.location = location
        self.roomId = roomId
        self.start = start
        self.end = end
    }
    
    func getLocalTimeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, h:mm a"
        let dateStringStart = formatter.string(from: self.start)
        let dateStringEnd = formatter.string(from: self.end)
        return "\(dateStringStart) -> \(dateStringEnd)"
    }
    
    func getRoomName() -> String {
        if name != nil { return name! } else { return location.name }
    }
}

class GSRGroupBooking {
    var group: GSRGroup!
    var bookings: [GSRBooking]!
    
    init(group: GSRGroup, bookings: [GSRBooking]) {
        self.group = group
        self.bookings = bookings
    }
}
