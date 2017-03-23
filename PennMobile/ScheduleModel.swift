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
        return event.occurs(at: self.startTime) || self.occurs(at: event.startTime)
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
    
    //returns all conflicting events, including itself
    public func getAllConflictingEvents(for events: [Event]) -> [Event] {
        var conflictingEvents = [Event]()
        
        for thisEvent in events {
            if isConflicting(with: thisEvent) {
                conflictingEvents.append(thisEvent)
            }
        }
        return conflictingEvents
    }
    
    //returns all conflicting events, including the event itself, when most conflicting events occur
    public func getMaxConflictingEvents(for events: [Event]) -> [Event] {
        var maxEvents: [Event] = []
        
        let conflictingEvents = getAllConflictingEvents(for: events)
        
        for event in conflictingEvents {
            let startTime = event.startTime
            var tempEvents: [Event] = []
            
            for otherEvent in conflictingEvents {
                if otherEvent.occurs(at: startTime) {
                    tempEvents.append(otherEvent)
                }
            }
            
            if maxEvents.count < tempEvents.count {
                maxEvents = tempEvents
            }
            
        }
        
        return maxEvents
    }
    
    private static func getApprovable(for events: [Event]) -> [Event] {
        var tempEvents = events
        for event in events {
            let maxConflictingEvents = event.getMaxConflictingEvents(for: tempEvents)
            if maxConflictingEvents.count > 3 {
                for i in 3...(maxConflictingEvents.count - 1) {
                    if let index = tempEvents.index(of: maxConflictingEvents[i]) {
                        tempEvents.remove(at: index)
                    }
                }
            }
        }
        return tempEvents
    }
    
    private static func sortEvents(for events: [Event]) -> [Event] {
        return events.sorted { (event1, event2) -> Bool in
            let raw1 = event1.startTime.rawMinutes()
            let raw2 = event2.startTime.rawMinutes()
            
            //sort by latest event first
            if raw1 == raw2 {
                return event1.endTime.rawMinutes() > event2.endTime.rawMinutes()
            }
            
            return raw1 < raw2
        }
    }
    
    public static func approvableEvents(for events: [Event]) -> [Event] {
        let sortedEvents = Event.sortEvents(for: events)
        return Event.getApprovable(for: sortedEvents)
    }
}
