//
//  RefactorDiningHallExtensions.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/13/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import Foundation
import SwiftUI
import PennMobileShared

public extension RefactorDiningHall {
    func statusText() -> String {
        let status = self.currentStatus()
        
        switch status {
        case .open(let closingSoon, let currentMeal):
            if closingSoon {
                return "Closing in \(String(format: "%.0f",Date.now.distance(to: currentMeal.endTime) / 60))m"
            } else {
                return self.venueType == .dining ? currentMeal.service : "Open"
            }
        case .closedIndefinitely:
            return "Closed indefinitely"
        case .closedUntil(let nextMeal):
            let dateFormatter = DateFormatter()
            if (Calendar.current.isDateInToday(nextMeal.startTime)) {
                dateFormatter.timeStyle = .short
                dateFormatter.amSymbol = "am"
                dateFormatter.pmSymbol = "pm"
                dateFormatter.timeZone = Calendar.current.timeZone
            } else {
                if (Calendar.current.isDateInTomorrow(nextMeal.startTime)) {
                    return "Closed until tomorrow"
                }
                dateFormatter.dateFormat = "EEEE" // day of week (i.e. "Wednesday")
            }
            return "Closed until \(dateFormatter.string(from: nextMeal.startTime))"
        case .openingSoon(let nextMeal):
            return "Opening in \(String(format: "%.0f",Date.now.distance(to: nextMeal.startTime) / 60))m"
        }
    }
    
    func currentStatus() -> DiningHallStatus {
        //handle open
        for meal in self.meals {
            if Date.now.localTime >= meal.startTime.localTime && Date.now.localTime < meal.endTime.localTime {
                let isClosingSoon = Date.now.localTime.distance(to: meal.endTime.localTime) < (45 * 60)
                return .open(isClosingSoon, meal)
            }
        }
        
        //the remaining cases are where the hall is closed
        let upcomingMeals: [RefactorDiningMeal] = self.meals.filter({Date.now.localTime < $0.startTime.localTime})
        
        if let nextMeal = upcomingMeals.first, Date.now.localTime.distance(to: nextMeal.startTime.localTime) < (3 * 24 * 60 * 60) { // < 72 hours and non-empty array
            if Date.now.localTime.distance(to: nextMeal.startTime.localTime) < (45 * 60) { // 45 minutes
                return .openingSoon(nextMeal)
            }
            return .closedUntil(nextMeal)
        }
        return .closedIndefinitely
    }
    
    func mealsToday() -> [RefactorDiningMeal] {
        return self.meals.filter { el in
            return Calendar.current.isDateInToday(el.startTime.localTime)
        }
    }
    
    
    enum DiningHallStatus {
        //boolean is "Closing Soon" (where soon is < 45m)
        case open(Bool, RefactorDiningMeal)
        case closedIndefinitely
        case closedUntil(RefactorDiningMeal)
        case openingSoon(RefactorDiningMeal)
        
        var iconString: String {
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
        
        var bgColor: Color {
            switch self {
            case .open(let isClosingSoon, _):
                return isClosingSoon ? Color.redLight : Color.greenLight
            case .closedIndefinitely, .closedUntil(_), .openingSoon(_):
                return Color.grey6
            }
        }
        
        var labelColor: Color {
            switch self {
            case .open(let isClosingSoon, _):
                return isClosingSoon ? Color.red : Color.green
            case .closedIndefinitely, .closedUntil(_), .openingSoon(_):
                return Color.grey2
            }
        }
        
        var textColor: Color {
            switch self {
            case .open(let isClosingSoon, _):
                return .white
            case .closedIndefinitely, .closedUntil(_), .openingSoon(_):
                return .labelPrimary
            }
        }
        
        var relevantMeal: RefactorDiningMeal? {
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
