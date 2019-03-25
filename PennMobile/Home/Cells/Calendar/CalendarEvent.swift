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
    
    func getDateString(fullLength: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = fullLength ? "EEEE, MMM. d" : "E. MMM. d"
        
        let startString = "\(formatter.string(from: start))"
        let endString = "\(formatter.string(from: end))"
        
        if (startString == endString) {
            formatter.dateFormat = "EEEE, MMM. d"
            let date = "\(formatter.string(from: start))"
            return date
        }
        return startString + " - " + endString
    }
}

extension CalendarEvent: Equatable {
    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        return lhs.name == rhs.name
            && lhs.start == rhs.start
            && lhs.end == rhs.end
    }
}
