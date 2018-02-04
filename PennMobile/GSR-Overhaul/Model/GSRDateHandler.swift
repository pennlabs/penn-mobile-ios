//
//  GSRDateModel.swift
//  PennMobile
//
//  Created by Josh Doman on 2/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

public struct GSROverhaulDate {
    var string: String
    var dayOfWeek: String
    var day: Int
}

class GSRDateHandler {
    static func generateDates() -> [GSROverhaulDate] {
        var dates = [GSROverhaulDate]()
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "EST")!
        
        let startDate = cal.startOfDay(for: Date())
        let endDate = startDate.dateIn(days: 6)
        
        let dateRange = cal.dateRange(startDate: startDate,
                                      endDate: endDate,
                                      stepUnits: .day,
                                      stepValue: 1)
        
        for date in dateRange {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            let string = formatter.string(from: date)
            let day = (cal as NSCalendar).components(NSCalendar.Unit.day, from: date).day
            dates.append(GSROverhaulDate(string: string, dayOfWeek: date.dayOfWeek, day: day!))
        }
        
        return dates
    }
}
