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

typealias GSRGroupRoomBookings = [GSRGroupRoomBooking]
class GSRGroupBooking {
    var group: GSRGroup!
    var bookings: GSRGroupRoomBookings!
    
    init(group: GSRGroup, bookings: [GSRGroupRoomBooking]) {
        self.group = group
        self.bookings = bookings
    }
}

struct GSRGroupRoomBooking {
    var roomName: String?
    var roomid: Int
    var location: GSRLocation
    var start: Date
    var end: Date
    var bookingSlots: [GSRGroupBookingSlot]

    init(roomid: Int, roomName: String?, location: GSRLocation, start: Date, end: Date, bookingSlots: [GSRGroupBookingSlot]) {
        self.roomid = roomid
        self.roomName = roomName
        self.location = location
        self.start = start
        self.end = end
        self.bookingSlots = bookingSlots
    }
    
    init(roomid: Int, roomName: String?, location: GSRLocation, start: Date, end: Date) {
        self.roomid = roomid
        self.roomName = roomName
        self.location = location
        self.start = start
        self.end = end
        
        //Splits the booking into (e.g. 30 minute) intervals, and stores it in bookingSlots
        bookingSlots = [GSRGroupBookingSlot]()
        #warning("DONT HARDCODE 30 minutes!")
        let interval = Double(30 * 60)
        var tempStart = start
        var tempEnd = tempStart.addingTimeInterval(interval)
        
        while (tempEnd <= end) {
            let slot = GSRGroupBookingSlot(start: tempStart, end: tempEnd)
            bookingSlots.append(slot)
            
            tempStart = tempEnd
            tempEnd = tempStart.addingTimeInterval(interval)
        }
    }
    
}
struct GSRGroupBookingSlot: Decodable {
    var start: Date
    var end: Date
    var booked: Bool?
    var pennkey: String?
    
    init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
    
    func strRange() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    enum CodingKeys: String, CodingKey {
        case start, end, booked, pennkey
    }
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let start: String = try keyedContainer.decode(String.self, forKey: .start)
        let end: String = try keyedContainer.decode(String.self, forKey: .end)
        let formatter = ISO8601DateFormatter()
        guard let startDate = formatter.date(from: start) else {
            let context = DecodingError.Context(codingPath: [GSRGroupBookingSlot.CodingKeys.start], debugDescription: "Incorrect Date Format")
            throw DecodingError.typeMismatch(Date.self, context)
        }
        guard let endDate = formatter.date(from: end) else {
            let context = DecodingError.Context(codingPath: [GSRGroupBookingSlot.CodingKeys.start], debugDescription: "Incorrect Date Format")
            throw DecodingError.typeMismatch(Date.self, context)
        }
        let booked = try keyedContainer.decode(Bool.self, forKey: .booked)
        if let pennkey = try? keyedContainer.decode(String.self, forKey: .pennkey) {
            self.pennkey = pennkey
        }

        self.start = startDate
        self.end = endDate
        self.booked = booked
    }
}
class GSRGroupRoomBookingResponse: Decodable {
    var lid: String!
    var roomid: String!
    var bookings: [GSRGroupBookingSlot]!
    
    enum CodingKeys: String, CodingKey {
        case roomid = "room"
        case lid, bookings
    }
}

class GSRGroupBookingResponse: Decodable {
    var partialSuccess: Bool!
    var completeSuccess: Bool!
    var error: String?
    var rooms: [GSRGroupRoomBookingResponse]!
    
    enum CodingKeys: String, CodingKey {
        case partialSuccess = "partial_success"
        case completeSuccess = "complete_success"
        case error, rooms
    }
}
