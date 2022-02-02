//
//  GSRDateModel.swift
//  PennMobile
//
//  Created by Josh Doman on 2/3/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

public struct GSRDate {
    var string: String
    var dayOfWeek: String
    var day: Int
}

class GSRDateHandler {
    static func generateDates() -> [GSRDate] {
        var dates = [GSRDate]()
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
            formatter.timeZone = TimeZone(abbreviation: "EST")!
            formatter.dateFormat = "yyyy-MM-dd"
            let string = formatter.string(from: date)
            let day = (cal as NSCalendar).components(NSCalendar.Unit.day, from: date).day
            dates.append(GSRDate(string: string, dayOfWeek: date.dayOfWeek, day: day!))
        }
        return dates
    }
}


//
//  NSDateExtension.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

extension Calendar {
    func dateRange(startDate: Foundation.Date, endDate: Foundation.Date, stepUnits: NSCalendar.Unit, stepValue: Int) -> DateRange {
        return DateRange(calendar: self, startDate: startDate, endDate: endDate,
                         stepUnits: stepUnits, stepValue: stepValue, multiplier: 0)
    }
}

struct DateRange: Sequence {
    
    var calendar: Calendar
    var startDate: Foundation.Date
    var endDate: Foundation.Date
    var stepUnits: NSCalendar.Unit
    var stepValue: Int
    fileprivate var multiplier: Int
    
    func makeIterator() -> Iterator {
        return Iterator(range: self)
    }
    
    struct Iterator: IteratorProtocol {
        
        var range: DateRange
        
        mutating func next() -> Foundation.Date? {
            guard let nextDate = (range.calendar as NSCalendar).date(byAdding: range.stepUnits,
                                                                     value: range.stepValue * range.multiplier,
                                                                     to: range.startDate,
                                                                     options: []) else {
                                                                        return nil
            }
            range.multiplier += 1
            return nextDate > range.endDate ? nil : nextDate
        }
    }
}
