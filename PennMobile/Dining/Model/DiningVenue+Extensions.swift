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
        case .dining: return "Dining Halls"
        case .retail: return "Retail Dining"
        case .unknown: return "Other"
        }
    }
}

// MARK: - DiningVenue
extension DiningVenue {
    
    // MARK: - Defaults
    static let defaultVenueIds: [Int] = [593, 636, 1442]
    
    // MARK: - Venue Status
    var mealsToday: MealsForDate? {
        return self.meals[DiningVenue.dateFormatter.string(from: Date())]
    }
    
    var isOpen: Bool {
        guard let mealsToday = mealsToday else { return false }
        for meal in mealsToday.meals {
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
        guard let _ = mealsToday else { return "" }
        return formattedHoursStringFor(Date())
    }
    
    func formattedHoursStringFor(_ date: Date) -> String {
        let dateString = DiningVenue.dateFormatter.string(from: date)
        return formattedHoursStringFor(dateString)
    }
    
    func formattedHoursStringFor(_ dateString: String) -> String {
        guard let meals = self.meals[dateString]?.meals else { return "" }
        
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
            
            if m.close.minutes == 0 {
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
        
        if meals.isEmpty {
            timesString = ""
        }
        return timesString
    }
}

// MARK: - Meal
extension DiningVenue.MealsForDate.Meal {
    var isCurrentlyServing: Bool {
        let now = Date()
        return (self.open <= now && self.close > now)
    }
}
