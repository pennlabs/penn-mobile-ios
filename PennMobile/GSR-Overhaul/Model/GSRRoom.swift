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
        return lhs.id == rhs.id
    }
}

extension Array where Element == GSRRoom {
    func getMinMaxDates(day: GSROverhaulDate) -> (Date, Date) {
        let midnightYesterday = midnight(for: day.string)
        let midnightToday = midnightYesterday.tomorrow

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
    
    private func midnight(for dateStr: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: dateStr)!
    }
}
