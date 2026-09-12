//
//  Date+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import Foundation

public extension Date {
    func minutesFrom(date: Date) -> Int {
        let difference = Calendar.current.dateComponents([.hour, .minute], from: self, to: date)
        if let hour = difference.hour, let minute = difference.minute {
            return hour*60 + minute
        }
        return 0
    }
    
    func hoursFrom(date: Date) -> Int {
        let difference = Calendar.current.dateComponents([.hour], from: self, to: date)
        return difference.hour ?? 0
    }
    
    func humanReadableDistanceFrom(_ date: Date) -> String {
        // Opens in 55m
        // Opens at 6pm
        let minutes = minutesFrom(date: date) % 60
        let hours = hoursFrom(date: date)
        var result = ""
        if hours != 0 {
            result += "at \(date.strFormat())"
        } else {
            result += "in \(minutes)m"
        }
        return result
    }
    
    // returns date in local time
    static var currentLocalDate: Date {
        return Date().localTime
    }
    
    func convert(to timezone: String) -> Date {
        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = Calendar.current.component(.year, from: self)
        nowComponents.month = Calendar.current.component(.month, from: self)
        nowComponents.day = Calendar.current.component(.day, from: self)
        nowComponents.hour = Calendar.current.component(.hour, from: self)
        nowComponents.minute = Calendar.current.component(.minute, from: self)
        nowComponents.second = Calendar.current.component(.second, from: self)
        nowComponents.timeZone = TimeZone(abbreviation: timezone)!
        return calendar.date(from: nowComponents)! as Date
    }
    
    // Formats individual dates to be similar to those used on the Dining Screen
    func strFormat() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        var timesString = ""
        
        if self.minutes == 0 {
            formatter.dateFormat = "ha"
        } else {
            formatter.dateFormat = "h:mma"
        }
        
        let open = formatter.string(from: self)
        timesString += open
        return timesString
    }
    
    var localTime: Date {
        return self.convert(to: "GMT")
    }
    
    var minutes: Int {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: self)
        return minutes
    }
    
    var hour: Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        return hour
    }
    
    static func shortHourLabel(for hour: Int) -> String {
        switch hour {
        case 0, 24: return "12a"
        case 1..<12: return "\(hour)a"
        case 12: return "\(hour)p"
        case 13..<24: return "\(hour - 12)p"
        default: return ""
        }
    }
    
    func add(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func add(months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self)!
    }
    
    func add(seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }
    
    func add(milliseconds: Int) -> Date {
        let millisecondsSince1970 = Int((self.timeIntervalSince1970 * 1000.0).rounded())
        return Date(timeIntervalSince1970: TimeInterval((milliseconds + millisecondsSince1970) / 1000))
    }
    
    var roundedDownToHour: Date {
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self)
        return Calendar.current.date(from: comp)!
        // return self.add(minutes: -self.minutes)
    }
    
    var month: Int {
        let values = Calendar.current.dateComponents([Calendar.Component.month], from: self)
        return values.month!
    }
    
    var year: Int {
        let values = Calendar.current.dateComponents([Calendar.Component.year], from: self)
        return values.year!
    }
    
    var roundedDownToHalfHour: Date {
        let roundedDownToHour = self.roundedDownToHour
        if roundedDownToHour.minutesFrom(date: self) >= 30 {
            return roundedDownToHour.add(minutes: 30)
        } else {
            return roundedDownToHour
        }
    }
    
    var roundUpToHourIfNeeded: Date {
        if minutes > 0 {
            return self.add(minutes: 60 - self.minutes)
        } else {
            return self
        }
    }
    
    static var currentDayOfWeek: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // Monday, Friday, etc.
        return dateFormatter.string(from: Date())
    }
    
    static let weekdayArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var dayOfWeek: String {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        myCalendar.timeZone = TimeZone(abbreviation: "EST")!
        let myComponents = myCalendar.components(.weekday, from: self)
        let weekDay = myComponents.weekday!
        return Date.weekdayArray[weekDay-1]
    }
    
    var integerDayOfWeek: Int {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.weekday, from: self)
        return myComponents.weekday! - 1
    }
    
    static let dayOfMonthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(abbreviation: "EST")
        return df
    }()
    
    var dateStringsForCurrentWeek: [String] {
        var dateStrings = [String]()
        let formatter = Date.dayOfMonthFormatter
        let currentDayOfWeek = Date().integerDayOfWeek
        for day in 0 ..< 7 {
            dateStrings.append(formatter.string(from: Date().add(minutes: 1440 * (day - currentDayOfWeek))))
        }
        return dateStrings
    }
    
    var adjustedFor11_59: Date {
        if self.minutes == 59 {
            return self.add(minutes: 1)
        }
        return self
    }
    
    func dateIn(days: Int) -> Date {
        let start = Calendar.current.startOfDay(for: self)
        return Calendar.current.date(byAdding: .day, value: days, to: start)!
    }
    
    var tomorrow: Date {
        return self.dateIn(days: 1)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    static func midnight(for dateStr: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: dateStr)!
    }
    
    static var midnightYesterday: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let dateStr = formatter.string(from: Date())
        return formatter.date(from: dateStr)!
    }
    
    static var midnightToday: Date {
        return midnightYesterday.tomorrow
    }
    
    static var todayString: String {
        return Date.dayOfMonthFormatter.string(from: Date())
    }
    
    static var startOfSemester: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: "2026-08-25")!
        
    }
    
    static var endOfSemester: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: "2026-12-17")!
    }
}
