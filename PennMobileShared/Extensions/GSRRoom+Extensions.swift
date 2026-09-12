//
//  GSRRoom+Extensions.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

public extension GSRRoom {
    func withMissingTimeslots(minDate: Date, maxDate: Date) -> GSRRoom {
        var newTimes = [GSRTimeSlot]()
        
        if availability.isEmpty {
            var currTime = minDate
            while currTime < maxDate {
                newTimes.append(GSRTimeSlot(startTime: currTime, endTime: currTime.add(minutes: 30), isAvailable: false))
                currTime = currTime.add(minutes: 30)
            }
            return GSRRoom(roomName: self.roomName, id: self.id, availability: newTimes)
        }

        if let earliestTime = availability.first {
            var currTime = earliestTime
            let minTime = minDate.add(minutes: 30)
            while currTime.startTime >= minTime {
                let newTimeSlot = GSRTimeSlot(startTime: currTime.startTime.add(minutes: -30), endTime: currTime.startTime, isAvailable: false)
                newTimes.insert(newTimeSlot, at: 0)
                currTime = newTimeSlot
            }
        }

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
