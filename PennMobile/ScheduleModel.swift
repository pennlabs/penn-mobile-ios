//
//  ScheduleModel.swift
//  PennMobile
//
//  Created by Josh Doman on 3/8/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

struct Time: Hashable {
    let hour: Int
    let minutes: Int
    let isAm: Bool
    
    func rawMinutes() -> Int {
        if isAm && hour == 12 {
            return minutes
        }
        var total = hour * 60 + minutes
        if !isAm && hour != 12 {
            total += 12*60
        }
        return total
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Time, rhs: Time) -> Bool {
        return lhs.hour == rhs.hour && lhs.minutes == rhs.minutes && lhs.isAm == rhs.isAm
    }
    
    var hashValue: Int {
        get {
            var hash = hour.hashValue
            hash += (55*hash + minutes.hashValue)
            hash += (55*hash + isAm.hashValue)
            return hash
        }
    }
}

struct Event: Hashable {
    let name: String
    let location: String?
    let startTime: Time
    let endTime: Time
    
    func isConflicting(with event: Event) -> Bool {
        return event.occurs(at: startTime) || self.occurs(at: event.startTime)
    }
    
    func occurs(at time: Time) -> Bool {
        let eventStartTime = startTime.rawMinutes()
        var eventEndTime = endTime.rawMinutes()
        
        if eventEndTime < eventStartTime {
            eventEndTime += 24*60
        }
        
        let rawTime = time.rawMinutes()
        
        return rawTime >= eventStartTime && rawTime < eventEndTime
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.name == rhs.name && lhs.location == rhs.location && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
    }
    
    var hashValue: Int {
        get {
            var hash = name.hashValue
            print(name.hashValue)
            if let location = location {
                print(location)
                print(location.hashValue)
                hash += (3*hash + location.hashValue)
            }
            hash += (3*hash + startTime.hashValue)
            hash += (3*hash + endTime.hashValue)
            return hash
        }
    }
}
