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
    
    var currentMeal: MealsForDate.Meal? {
        return self.mealsToday?.meals.first(where: { $0.isCurrentlyServing }) ?? nil
    }
    
    var currentMealIndex: Int? {
        return self.mealsToday?.meals.firstIndex(where: { $0.isCurrentlyServing }) ?? nil
    }
    
    var currentMealType: String? {
        return self.currentMeal?.type ?? nil
    }
    
    var isClosingSoon: Bool {
        return Date().minutesFrom(date: currentMeal?.close ?? Date()) < 15
    }
    
    var timeLeft: String {
        return Date().humanReadableDistanceFrom(currentMeal?.close ?? Date())
    }
    
    var nextMeal: MealsForDate.Meal? {
        guard let mealsToday = mealsToday else { return nil }
        let now = Date()
        return mealsToday.meals.first(where: { $0.open > now })
    }
    
    var hasMealsToday: Bool {
        return mealsToday != nil
    }
    
    var nextOpenedDayOfTheWeek: String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let sortedMeals = self.meals.sorted(by: {
            formatter.date(from: $0.key)! < formatter.date(from: $1.key)!
        })
        
        for meal in sortedMeals {
            if formatter.date(from: meal.key) ?? Date() > Date() && meal.value.meals.count != 0 {
                return "until \(formatter.date(from: meal.key)?.dayOfWeek ?? "N/A")"
            }
        }
        
        return "Indefinitely"
    }
    
    var isMainDiningTimes: Bool {
        return (currentMealType == "Breakfast" || currentMealType == "Lunch" || currentMealType == "Dinner")
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
        formatter.dateFormat = "h:mm"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        
        var firstMeal = true
        var timesString = ""
        let moreThanOneMeal = meals.count > 1
        
        for m in meals {
            if m.open.minutes == 0 {
                formatter.dateFormat = moreThanOneMeal ? "h" : "h"
            } else {
                formatter.dateFormat = moreThanOneMeal ? "h:mm" : "h:mm"
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
    
    var humanFormattedHoursArrayForToday: [String] {
        guard let _ = mealsToday else { return [] }
        return formattedHoursArrayFor(Date())
    }
    
    func formattedHoursArrayFor(_ date: Date) -> [String] {
        let dateString = DiningVenue.dateFormatter.string(from: date)
        return formattedHoursArrayFor(dateString)
    }
    
    func formattedHoursArrayFor(_ dateString: String) -> [String] {
        
        var formattedHoursArray = [String]()
        
        guard let meals = self.meals[dateString]?.meals else { return [] }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "h:mm"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        
        let moreThanOneMeal = meals.count > 1
        
        for m in meals {
            if m.open.minutes == 0 {
                formatter.dateFormat = moreThanOneMeal ? "h" : "h"
            } else {
                formatter.dateFormat = moreThanOneMeal ? "h:mm" : "h:mm"
            }
            let open = formatter.string(from: m.open)
            
            if m.close.minutes == 0 {
                formatter.dateFormat = moreThanOneMeal ? "h" : "ha"
            } else {
                formatter.dateFormat = moreThanOneMeal ? "h:mm" : "h:mma"
            }
            let close = formatter.string(from: m.close)
            
            formattedHoursArray.append("\(open) - \(close)")
        }
        
        return formattedHoursArray
    }
    
    var statusString : String {
        if hasMealsToday {
            if isOpen {
                if isClosingSoon {
                    return "Closes \(timeLeft)"
                } else {
                    switch venueType {
                    case .dining:
                        return currentMealType!
                    default:
                        return "Open"
                    }
                    
                }
            } else if let nextMeal = nextMeal {
                switch venueType {
                case .dining:
                    return "\(nextMeal.type) \(Date().humanReadableDistanceFrom(nextMeal.open))"
                default:
                    return "Opens \(Date().humanReadableDistanceFrom(nextMeal.open))"
                }
            } else {
                return "Closed \(nextOpenedDayOfTheWeek)"
            }
        } else {
            return "Closed \(nextOpenedDayOfTheWeek)"
        }
    }
}

// MARK: - Meal
extension DiningVenue.MealsForDate.Meal {
    var isCurrentlyServing: Bool {
        let now = Date()
        return (self.open <= now && self.close > now)
    }
    
    var isLight: Bool {
        return self.type.contains("Light")
    }
}
