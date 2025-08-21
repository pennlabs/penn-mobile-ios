//
//  GSRRoom.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

struct GSRRoom: Codable, Hashable, Identifiable, Comparable {
    static func < (lhs: GSRRoom, rhs: GSRRoom) -> Bool {
        // 1. Two rooms with a letter preceding numbers should be sorted by that letter, then by the number
        // 2. Rooms with letters before a number should appear before rooms with just a number
        // 3. Two rooms with just numbers should be sorted by those numbers
        // 4. Rooms without numbers should be sorted alphabetically
        
        // Case 1
        if let lhsLetter = lhs.precedingRoomLetter, let rhsLetter = rhs.precedingRoomLetter {
            if lhsLetter != rhsLetter {
                return lhsLetter < rhsLetter
            } else {
                if let lhsNum = lhs.roomNumber, let rhsNum = rhs.roomNumber {
                    return lhsNum < rhsNum
                } else {
                    return lhs.roomName < rhs.roomName
                }
            }
        }
        
        // Case 2
        if let lhsLetter = lhs.precedingRoomLetter {
            // Place LHS first
            return true
        }
        
        // Case 3
        if let lhsNum = lhs.roomNumber, let rhsNum = rhs.roomNumber {
            return lhsNum < rhsNum
        }
        
        // Case 4
        return lhs.roomName < rhs.roomName
        
    }
    
    let roomName: String
    let id: Int
    var availability: [GSRTimeSlot]
    
    var roomNumber: Int? {
        let regex = /[0-9]+/
        if let match = roomNameShort.firstMatch(of: regex), let numInt = Int(match.0) {
            return numInt
        }
        return nil
    }
    
    var precedingRoomLetter: String? {
        let regex = /([A-Z])([0-9]+)/
        if let match = roomNameShort.firstMatch(of: regex) {
            return String(match.1)
        }
        return nil
    }
    
    var roomNameShort: String {
        self.roomName.split(separator: ":").first?.trimmingCharacters(in: .whitespaces) ?? roomName
    }
}

extension Array where Element == GSRRoom {
    func getMinMaxDates() -> (Date?, Date?) {
        var min: Date?
        var max: Date?
        for room in self {
            if let firstStartTime = room.availability.first?.startTime, min == nil || (firstStartTime < min!) {
                min = firstStartTime
            }
            if let lastEndTime = room.availability.last?.endTime, max == nil || (lastEndTime > max!) {
                max = lastEndTime
            }
        }
        return (min, max)
    }
    
    func hasAvailableAt(_ startTime: Date) -> Bool {
        return !self.filter({ $0.availability.contains(where: { $0.startTime == startTime && $0.isAvailable }) }).isEmpty
    }
}

extension GSRRoom {
    func withMissingTimeslots(minDate: Date, maxDate: Date) -> GSRRoom {
        var newTimes = [GSRTimeSlot]()
        
        // If slot has no availability:
        if availability.isEmpty {
            var currTime = minDate
            while currTime < maxDate {
                newTimes.append(GSRTimeSlot(startTime: currTime, endTime: currTime.add(minutes: 30), isAvailable: false))
                currTime = currTime.add(minutes: 30)
            }
            return GSRRoom(roomName: self.roomName, id: self.id, availability: newTimes)
        }

        // Fill in early slots
        if let earliestTime = availability.first {
            var currTime = earliestTime
            let minTime = minDate.add(minutes: 30)
            while currTime.startTime >= minTime {
                let newTimeSlot = GSRTimeSlot(startTime: currTime.startTime.add(minutes: -30), endTime: currTime.startTime, isAvailable: false)
                newTimes.insert(newTimeSlot, at: 0)
                currTime = newTimeSlot
            }
        }

        // Fill in middle slots
        for i in 0..<availability.count {
            var prevTime = availability[i]
            newTimes.append(prevTime)

            if i == availability.count - 1 { break }
            let nextTime = availability[i+1]

            while prevTime.endTime < nextTime.startTime {
                let newTimeSlot = GSRTimeSlot(startTime: prevTime.endTime, endTime: prevTime.endTime.add(minutes: 30), isAvailable: false)
                newTimes.append(newTimeSlot)
                prevTime = newTimeSlot
            }
        }

        // Fill in early slots
        if let latestTime = availability.last {
            var currTime = latestTime
            let maxTime = maxDate.add(minutes: -30)
            while currTime.endTime <= maxTime {
                let newTimeSlot = GSRTimeSlot(startTime: currTime.endTime, endTime: currTime.endTime.add(minutes: 30), isAvailable: false)
                newTimes.append(newTimeSlot)
                currTime = newTimeSlot
            }
        }

        return GSRRoom(roomName: self.roomName, id: self.id, availability: newTimes)
    }
}
