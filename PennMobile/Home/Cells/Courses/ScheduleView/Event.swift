//
//  Event.swift
//  Wen
//
//  Created by Josh Doman on 4/5/17.
//  Copyright © 2017 Josh Doman. All rights reserved.
//

class Event: Hashable {
    let name: String
    let location: String?
    let startTime: Time
    let endTime: Time
    
    init(name: String, location: String?, startTime: Time, endTime: Time) {
        self.name = name
        self.location = location
        self.startTime = startTime
        self.endTime = endTime
    }
    
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
    
    //Events for Agenda Cell
    static let mockEvents: [Event] = {
        let event1 = Event(name: "LGST101", location: "SHDH 211", startTime: Time(hour: 8, minutes: 0, isAm: true), endTime: Time(hour: 9, minutes: 0, isAm: true))
        
        let event2 = Event(name: "MEAM101", location: "TOWN 101", startTime: Time(hour: 9, minutes: 0, isAm: true), endTime: Time(hour: 11, minutes: 0, isAm: true))
        
        let event3 = Event(name: "FNAR264", location: "FSHR 203", startTime: Time(hour: 11, minutes: 0, isAm: true), endTime: Time(hour: 12, minutes: 0, isAm: false))
        
        let event4 = Event(name: "MATH240", location: "HUNT 250", startTime: Time(hour: 11, minutes: 0, isAm: true), endTime: Time(hour: 3, minutes: 0, isAm: false))
        
        let event5 = Event(name: "GSWS101", location: "WILL 027", startTime: Time(hour: 1, minutes: 0, isAm: false), endTime: Time(hour: 2, minutes: 0, isAm: false))
        
        let event6 = Event(name: "CIS160", location: "MOOR 100", startTime: Time(hour: 7, minutes: 0, isAm: true), endTime: Time(hour: 2, minutes: 0, isAm: false))
        
        let event7 = Event(name: "PennQuest", location: "Houston Hall", startTime: Time(hour: 3, minutes: 30, isAm: false), endTime: Time(hour: 5, minutes: 30, isAm: false))
        
        let event8 = Event(name: "CIS160", location: "Houston Hall", startTime: Time(hour: 2, minutes: 30, isAm: false), endTime: Time(hour: 3, minutes: 30, isAm: false))
        
        let event9 = Event(name: "PennLabs", location: "Houston Hall", startTime: Time(hour: 3, minutes: 30, isAm: false), endTime: Time(hour: 4, minutes: 30, isAm: false))
        
        let event10 = Event(name: "STAT430", location: "Huntsman", startTime: Time(hour: 4, minutes: 30, isAm: false), endTime: Time(hour: 7, minutes: 0, isAm: false))
        
        let event11 = Event(name: "Physics!", location: "DRL", startTime: Time(hour: 4, minutes: 30, isAm: false), endTime: Time(hour: 5, minutes: 30, isAm: false))
        
        let event12 = Event(name: "Sleep", location: "Home", startTime: Time(hour: 6, minutes: 30, isAm: false), endTime: Time(hour: 8, minutes: 0, isAm: false))

        
        return [event1, event2, event3, event4, event5, event6, event7, event8, event9, event10, event11, event12]
    }()
}

extension Array where Element: Course {
    func getEvents() -> [Event] {
        return self.map { $0.getEvent() }.filter { $0 != nil }.map { $0! }
    }
}

extension Array where Element: Event {
    func getTimes() -> [Time] {
        var times = [Time]()
        for event in self {
            let startTime = event.startTime
            if !times.contains(startTime) {
                times.append(startTime)
            }
            
            let endTime = event.endTime
            if !times.contains(endTime) {
                times.append(endTime)
            }
        }
        
        times.sort { (time1, time2) -> Bool in
            return time1.rawMinutes() < time2.rawMinutes()
        }
        return times
    }
}
