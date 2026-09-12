//
//  Array+Extensions.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

public extension Array where Element == GSRRoom {
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
