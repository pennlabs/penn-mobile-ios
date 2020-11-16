//
//  GSRRoom.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

// MARK: - Init
class GSRRoom {
    let name: String
    let roomId: Int
    let gid: Int
    let imageUrl: String?
    let capacity: Int
    var timeSlots: [GSRTimeSlot]! = nil
    
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
//        guard let lhsStart = lhs.timeSlots.first?.startTime, let rhsStart = rhs.timeSlots.first?.startTime else {
//            return false
//        }
//
//        if lhsStart == rhsStart {
//            let lhsNumRow = lhs.timeSlots.numberInRow
//            let rhsNumRow = rhs.timeSlots.numberInRow
//            if lhsNumRow == rhsNumRow {
//                return lhs.timeSlots.count > rhs.timeSlots.count
//            }
//            return lhsNumRow > rhsNumRow
//        } else {
//            return lhsStart < rhsStart
//        }
        if lhs.name.contains("F") {
            if rhs.name.contains("F") {
                return lhs.name < rhs.name
            } else {
                return true
            }
        } else if lhs.name.contains("G") {
            if rhs.name.contains("G") {
                return lhs.name < rhs.name
            } else {
                return true
            }
        } else {
            return lhs.name < rhs.name
        }
    }
    
    static func ==(lhs: GSRRoom, rhs: GSRRoom) -> Bool {
        return lhs.roomId == rhs.roomId
    }
}

extension Array where Element == GSRRoom {
    func getMinMaxDates(day: GSRDate) -> (Date?, Date?) {
        var min: Date? = nil
        var max: Date? = nil
        for room in self {
            if let firstStartTime = room.timeSlots.first?.startTime, min == nil || (firstStartTime < min!) {
                min = firstStartTime
            }
            if let lastEndTime = room.timeSlots.last?.endTime, max == nil || (lastEndTime > max!) {
                max = lastEndTime
            }
        }
        return (min, max)
    }
}

extension GSRRoom {
    func addMissingTimeslots(minDate: Date, maxDate: Date) {
        var newTimes = [GSRTimeSlot]()
        
        // Fill in early slots
        if let earliestTime = timeSlots.first {
            var currTime = earliestTime
            let minTime = minDate.add(minutes: 30)
            while currTime.startTime >= minTime {
                let currNewTime = GSRTimeSlot(roomId: roomId, isAvailable: false, startTime: currTime.startTime.add(minutes: -30), endTime: currTime.startTime)
                currNewTime.next = currTime
                currTime.prev = currNewTime
                newTimes.insert(currNewTime, at: 0)
                currTime = currNewTime
            }
        }
        
        // Fill in middle slots
        for i in 0..<timeSlots.count {
            var prevTime = timeSlots[i]
            newTimes.append(prevTime)
            
            if i == timeSlots.count - 1 { break }
            let nextTime = timeSlots[i+1]
            var currNewTime = prevTime
            
            while prevTime.endTime < nextTime.startTime {
                currNewTime = GSRTimeSlot(roomId: roomId, isAvailable: false, startTime: prevTime.endTime, endTime: prevTime.endTime.add(minutes: 30))
                prevTime.next = currNewTime
                currNewTime.prev = prevTime
                newTimes.append(currNewTime)
                prevTime = currNewTime
            }
        }
        
        // Fill in early slots
        if let latestTime = timeSlots.last {
            var currTime = latestTime
            let maxTime = maxDate.add(minutes: -30)
            while currTime.endTime <= maxTime {
                let currNewTime = GSRTimeSlot(roomId: roomId, isAvailable: false, startTime: currTime.endTime, endTime: currTime.endTime.add(minutes: 30))
                currNewTime.prev = currTime
                currTime.next = currNewTime
                newTimes.append(currNewTime)
                currTime = currNewTime
            }
        }
        
        self.timeSlots = newTimes
    }
}
