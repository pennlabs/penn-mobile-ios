//
//  DateHandler.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation

class DateHandler {
    fileprivate static func generateDates() -> [GSRDate] {
        var dates = [GSRDate]()
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "EST")!
        
        let startDate = cal.startOfDay(for: Foundation.Date())
        let endDate = startDate.dateIn(days: 6)
        
        let dateRange = cal.dateRange(startDate: startDate,
                                      endDate: endDate,
                                      stepUnits: .day,
                                      stepValue: 1)
        
        for date in dateRange {
            let locale = Locale(identifier: "en_US")
            let string = date.description(with: locale).components(separatedBy: ", 201")[0]
            let compact = date.dayOfWeek//date.description.components(separatedBy: " ")[0]
            let day = (cal as NSCalendar).components(NSCalendar.Unit.day, from: date).day
            dates.append(GSRDate(string: string, compact: compact, day: day!))
        }
        
        return dates
    }
    
    static func getDates() -> [GSRDate] {
        return generateDates()
    }
}
