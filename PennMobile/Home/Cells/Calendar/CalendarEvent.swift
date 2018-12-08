//
//  CalendarEvent.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 11/16/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class CalendarEvent {
    let start: Date
    let name: String
    let end: Date
    
    init(name: String, start: Date, end: Date) {
        self.name = name
        self.start = start
        self.end = end
    }
    
    func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let startString = "\(formatter.string(from: start))"
        let endString = "\(formatter.string(from: end))"
        
        return startString + " to " + endString
    }
    
    static func getDefaultCalendarEvent() -> CalendarEvent {
        let name = "Advance Registration"
        let startTimeStr = "2018-04-01"
        let endTimeStr = "2018-04-01"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let start = formatter.date(from: startTimeStr)!
        let end = formatter.date(from: endTimeStr)!
        
        return CalendarEvent(name: name, start: start, end: end)
    }
}

// MARK: - JSON Parsing
extension CalendarEvent {
    convenience init(json: JSON) throws {
        guard let name = json["name"].string,
            let startTimeStr = json["start"].string,
            let endTimeStr = json["end"].string
            else {
                throw NetworkingError.jsonError
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let startTime = formatter.date(from: startTimeStr), let endTime = formatter.date(from: endTimeStr) else {
            throw NetworkingError.jsonError
        }
        self.init(name: name, start: startTime, end: endTime)
    }
}

extension CalendarEvent: Equatable {
    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        return lhs.name == rhs.name
            && lhs.start == rhs.start
            && lhs.end == rhs.end
    }
}

extension Array where Element == CalendarEvent {
    func equals(_ arr: [CalendarEvent]) -> Bool {
        if arr.count != count {
            return false
        }
        
        for i in 0..<(count) {
            if self[i] != arr[i] {
                return false
            }
        }
        return true
    }
}
