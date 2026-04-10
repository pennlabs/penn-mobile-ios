//
//  RefactorDiningHallExtensions.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/13/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import Foundation
import SwiftUI

public extension Array where Element == DiningDay {
    var today: DiningDay? {
        return get(date: Date())
    }
    
    func get(date: Date) -> DiningDay? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return self.first(where: { day in
            guard let diningDate = formatter.date(from: day.date) else { return false }
            return Calendar.current.isDate(diningDate, inSameDayAs: date)
        })
    }
}

public extension Array where Element == DiningMenu {
    func matchMenu(with meal: Meal) -> DiningMenu? {
        return self.first(where: { menu in
            return menu.startTime == meal.starttime && menu.endTime == meal.endtime
        })
    }
}

public extension DiningVenue {
    func statusText() -> String {
        let status = self.currentStatus()
        
        switch status {
        case .open(let closingSoon, let currentMeal):
            if closingSoon {
                return "Closing in \(String(format: "%.0f",Date.now.distance(to: currentMeal.endtime) / 60))m"
            } else {
                return self.venueType == .dining ? currentMeal.label : "Open"
            }
        case .closedIndefinitely:
            return "Closed indefinitely"
        case .closedUntil(let nextMeal):
            let dateFormatter = DateFormatter()
            if (Calendar.current.isDateInToday(nextMeal.starttime)) {
                dateFormatter.timeStyle = .short
                dateFormatter.amSymbol = "am"
                dateFormatter.pmSymbol = "pm"
                dateFormatter.timeZone = Calendar.current.timeZone
            } else {
                if (Calendar.current.isDateInTomorrow(nextMeal.starttime)) {
                    return "Closed until tomorrow"
                }
                dateFormatter.dateFormat = "EEEE" // day of week (i.e. "Wednesday")
            }
            return "Closed until \(dateFormatter.string(from: nextMeal.starttime))"
        case .openingSoon(let nextMeal):
            return "Opening in \(String(format: "%.0f",Date.now.distance(to: nextMeal.starttime) / 60))m"
        }
    }
    
    func currentStatus() -> DiningHallStatus {
        //handle open
        for meal in self.mealsToday() {
            if Date.now >= meal.starttime && Date.now < meal.endtime {
                let isClosingSoon = Date.now.distance(to: meal.endtime) < (45 * 60)
                return .open(isClosingSoon, meal)
            }
        }
        
        //the remaining cases are where the hall is closed
        let nextThreeDays: [Meal] = (0..<3).flatMap({ self.days.get(date: Date().dateIn(days: $0))?.meals ?? [] })
        
        if let nextMeal = nextThreeDays.first(where: { Date.now < $0.starttime }) { // < 72 hours and non-empty array
            if Date.now.distance(to: nextMeal.starttime) < (45 * 60) { // 45 minutes
                return .openingSoon(nextMeal)
            }
            return .closedUntil(nextMeal)
        }
        return .closedIndefinitely
    }
    
    func mealsToday() -> [Meal] {
        return self.days.today?.meals ?? []
    }
    
    func mealsOnDate(_ date: Date) -> [Meal] {
        return self.days.get(date: date)?.meals ?? []
    }
    
    enum DiningHallStatus {
        //boolean is "Closing Soon" (where soon is < 45m)
        case open(Bool, Meal)
        case closedIndefinitely
        case closedUntil(Meal)
        case openingSoon(Meal)
        
        public var iconString: String {
            switch self {
            case .open(let isClosingSoon, _):
                return isClosingSoon ? "clock.fill" : "circle.fill"
            case .closedIndefinitely:
                return "xmark.circle.fill"
            case .closedUntil(_):
                return "pause.circle.fill"
            case .openingSoon(_):
                return "clock.fill"
            }
        }
        
        public var bgColor: Color {
            switch self {
            case .open(let isClosingSoon, _):
                return isClosingSoon ? Color.redLight : Color.greenLight
            case .closedIndefinitely, .closedUntil(_), .openingSoon(_):
                return Color.grey6
            }
        }
        
        public var labelColor: Color {
            switch self {
            case .open(let isClosingSoon, _):
                return isClosingSoon ? Color.redLight : Color.greenLight
            case .closedIndefinitely, .closedUntil(_), .openingSoon(_):
                return Color.grey2
            }
        }
        
        public var textColor: Color {
            switch self {
            case .open(let isClosingSoon, _):
                return .white
            case .closedIndefinitely, .closedUntil(_), .openingSoon(_):
                return .labelPrimary
            }
        }
        
        public var relevantMeal: Meal? {
            switch self {
            case .open(_, let meal):
                return meal
            case .closedIndefinitely:
                return nil
            case .closedUntil(let meal):
                return meal
            case .openingSoon(let meal):
                return meal
            }
        }
    }
}

public extension Meal {
    func getHumanReadableHours() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeZone = .current
        
        let calendar = Calendar.current
        
        let startHour = calendar.component(.hour, from: starttime)
        let startMinute = calendar.component(.minute, from: starttime)
        let endHour = calendar.component(.hour, from: endtime)
        let endMinute = calendar.component(.minute, from: endtime)
        
        // Determine if both times are AM or PM
        let isSamePeriod = (startHour < 12 && endHour < 12) || (startHour >= 12 && endHour >= 12)
        
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"

        //AM
        formatter.dateFormat = "h\(startMinute != 0 ? ":mm" : "")"
        let startTimeString = formatter.string(from: starttime)
        
        //PM
        formatter.dateFormat = "h\(endMinute != 0 ? ":mm" : "")\(!isSamePeriod ? "" : "a")"
        let endTimeString = formatter.string(from: endtime)
        
        return "\(startTimeString) - \(endTimeString)"
    }
}
