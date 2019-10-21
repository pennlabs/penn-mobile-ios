//
//  DiningVenue+UIExtensions.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

// MARK: - VenueType
extension DiningVenue.VenueType {
    var fullDisplayName: String {
        switch self {
        case .dining: return "Campus Dining Hall"
        case .retail: return "Campus Retail Dining"
        case .unknown: return "Other"
        }
    }
}

// MARK: - DiningVenue
extension DiningVenue {
    
    // MARK: - Venue Status
    var mealsToday: MealsForDate? {
        return self.meals?[DiningVenue.dateFormatter.string(from: Date())]
    }
    
    var isOpen: Bool {
        guard let mealsToday = mealsToday else { return }
        let now = Date()
        for meal in mealsToday {
            if meal.isCurrentlyServing {
                return true
            }
        }
        return false
    }
    
    var hasMealsToday: Bool {
        return mealsToday != nil
    }
    
    // MARK: - Formatted Hours
    var humanFormattedHoursStringForToday: String {
        guard let meals = mealsToday else { return "" }
        return formattedHoursStringFor(Date())
    }
    
    func formattedHoursStringFor(_ date: Date) -> String {
        let dateString = DiningVenue.dateFormatter.string(from: date)
        return formattedHoursStringFor(dateString)
    }
    
    func formattedHoursStringFor(_ dateString: String) -> String {
        guard let meals = self.meals?[dateString]?.meals else { return "" }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "a"
        formatter.pmSymbol = "p"
        
        var firstMeal = true
        var timesString = ""
        let moreThanOneMeal = meals.count > 1
        
        for m in meals {
            if m.open.minutes == 0 {
                formatter.dateFormat = moreThanOneMeal ? "h" : "ha"
            } else {
                formatter.dateFormat = moreThanOneMeal ? "h:mm" : "h:mma"
            }
            let open = formatter.string(from: m.open)
            
            if open_close.close.minutes == 0 {
                formatter.dateFormat = moreThanOneMeal ? "h" : "ha"
            } else {
                formatter.dateFormat = moreThanOneMeal ? "h:mm" : "h:mma"
            }
            let close = formatter.string(from: m.close)
            
            if firstMeal {
                firstMeal = false
            } else {
                timesString += "  |  "
            }
            timesString += "\(open) - \(close)"
        }
        
        if self.isEmpty {
            timesString = ""
        }
        return timesString
    }
}

extension DiningVenue.MealsForToday.Meal {
    var isCurrentlyServing: Bool {
        let now = Date()
        return (meal.open <= now && meal.close > now)
    }
}
