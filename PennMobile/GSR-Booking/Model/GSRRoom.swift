//
//  GSRRoom.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

struct GSRRoom: Codable {
    let roomName: String
    let id: Int
    var availability: [GSRTimeSlot]
}

extension Array where Element == GSRRoom {
    func getMinMaxDates() -> (Date?, Date?) {
        var min: Date? = nil
        var max: Date? = nil
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
}

extension GSRRoom {
    func addMissingTimeslots(minDate: Date, maxDate: Date) -> [GSRTimeSlot] {
        var newTimes = [GSRTimeSlot]()

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

        return newTimes
    }
}
