//
//  NSDateExtension.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation

// greater than
func GT (left: Foundation.Date, right: Foundation.Date) -> Bool {
    return left.compare(right) == .orderedDescending
}

extension Calendar {
    func dateRange(startDate: Foundation.Date, endDate: Foundation.Date, stepUnits: NSCalendar.Unit, stepValue: Int) -> DateRange {
        let dateRange = DateRange(calendar: self, startDate: startDate, endDate: endDate,
                                  stepUnits: stepUnits, stepValue: stepValue, multiplier: 0)
        return dateRange
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
            if GT(left: nextDate, right: range.endDate) {
                return nil
            }
            else {
                range.multiplier += 1
                return nextDate
            }
        }
    }
}
