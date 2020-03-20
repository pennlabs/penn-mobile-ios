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
    
    func getSplitTimeRanges(interval: TimeInterval) -> [ClosedRange<Date>] {
        ///Splits the booking into (e.g. 30 minute) intervals, and returns the array of date ranges
        var ranges = [ClosedRange<Date>]()
        var tempStart = start
        var tempEnd = tempStart.addingTimeInterval(interval)
        while (tempEnd <= end) {
            let range = tempStart...tempEnd
            ranges.append(range)
            tempStart = tempEnd
            tempEnd = tempStart.addingTimeInterval(interval)
        }
        return ranges
    }
}

typealias GSRBookings = [GSRBooking]

class GSRGroupBooking {
    var group: GSRGroup!
    var bookings: GSRBookings!
    
    init(group: GSRGroup, bookings: [GSRBooking]) {
        self.group = group
        self.bookings = bookings
    }
}


class GSRBookingSlotResponse: Codable {
    var start: String!
    var end: String!
    var booked: Bool!
    var pennkey: String?
}
class GSRBookingResponse: Codable {
    var lid: String!
    var roomid: String!
    var bookings: [GSRBookingSlotResponse]!
}

class GSRGroupBookingResponse: Codable {
    var partialSuccess: Bool!
    var completeSuccess: Bool!
    var error: String?
    var rooms: [GSRBookingResponse]!
    
    enum CodingKeys: String, CodingKey {
        case partialSuccess = "partial_success"
        case completeSuccess = "complete_success"
        case error, rooms
    }
}
