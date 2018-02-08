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
    let roomId: Int
    let gid: Int
    let imageUrl: String?
    let capacity: Int
    let timeSlots: [GSRTimeSlot]
    
    init(name: String, roomId: Int, gid: Int, imageUrl: String?, capacity: Int, timeSlots: [GSRTimeSlot]) {
        self.name = name
        self.roomId = roomId
        self.gid = gid
        self.imageUrl = imageUrl
        self.capacity = capacity
        self.timeSlots = timeSlots
    }
}

extension GSRRoom: Comparable {
    static func <(lhs: GSRRoom, rhs: GSRRoom) -> Bool {
        guard let lhsStart = lhs.timeSlots.first?.startTime, let rhsStart = rhs.timeSlots.first?.startTime else {
            return false
        }
        
        if lhsStart == rhsStart {
            let lhsNumRow = lhs.timeSlots.numberInRow
            let rhsNumRow = rhs.timeSlots.numberInRow
            if lhsNumRow == rhsNumRow {
                return lhs.timeSlots.count > rhs.timeSlots.count
            }
            return lhsNumRow > rhsNumRow
        } else {
            return lhsStart < rhsStart
        }
    }
    
    static func ==(lhs: GSRRoom, rhs: GSRRoom) -> Bool {
        return lhs.roomId == rhs.roomId
    }
}

extension Array where Element == GSRRoom {
    func getMinMaxDates(day: GSRDate) -> (Date, Date) {
        let midnightYesterday = Date.midnightYesterday
        let midnightToday = Date.midnightToday

        if isEmpty {
            return (midnightYesterday, midnightToday)
        }

        var min = midnightToday
        var max = midnightYesterday
        for room in self {
            if let firstStartTime = room.timeSlots.first?.startTime, firstStartTime < min {
                min = firstStartTime
            }
            if let lastEndTime = room.timeSlots.last?.endTime, lastEndTime > max {
                max = lastEndTime
            }
        }
        return (min, max)
    }
}
