//
//  DiningVenue+UIExtensions.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

// MARK: - VenueType
public extension VenueType {
    var fullDisplayName: String {
        switch self {
        case .dining: return "Dining Halls"
        case .retail: return "Retail Dining"
        }
    }
}

// MARK: - DiningVenue
public extension DiningVenue {

    // MARK: - Venue Status
    var mealsToday: [Meal] {
        
        return mealsOnDate(date: Date())
    }
    
    func mealsOnDate(date: Date) -> [Meal] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return self.days.first(where: { day in
            day.date == dateFormatter.string(from: date)
        })?.meals.sorted(by: { el1, el2 in
            return el1.starttime > el2.starttime
        }) ?? []
    }

    var isOpen: Bool {
        if mealsToday.isEmpty { return false }
        
        for meal in mealsToday where meal.isCurrentlyServing {
            return true
        }
        
        return false
    }

    var currentMeal: Meal? {
        return self.mealsToday.first(where: { $0.isCurrentlyServing }) ?? nil
    }

    var currentMealType: String? {
        return self.currentMeal?.label ?? nil
    }

    var isClosingSoon: Bool {
        return Date().minutesFrom(date: currentMeal?.endtime ?? Date()) < 15
    }

    var timeLeft: String {
        return Date().humanReadableDistanceFrom(currentMeal?.endtime ?? Date())
    }

    var nextMeal: Meal? {
        if (!self.hasMealsToday) { return nil }
        
        return mealsToday.first(where: { $0.starttime > Date() })
    }

    var currentMealIndex: Int? {
        return self.mealsToday.firstIndex(where: { $0.isCurrentlyServing })
    }

    var currentOrNearestMealIndex: Int? {
        return self.mealsToday.firstIndex(where: { $0.isCurrentlyServing }) ?? (self.mealsToday.firstIndex(where: { $0.starttime > Date() }) ?? nil)
    }
    
    var currentOrNearestMeal: Meal? {
        return self.mealsToday.first(where: { $0.isCurrentlyServing }) ?? (self.mealsToday.first(where: { $0.starttime > Date() }) ?? nil)
    }

    var hasMealsToday: Bool {
        return mealsToday != []
    }

    var nextOpenedDayOfTheWeek: String {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for day in self.days {
            if formatter.date(from: day.date)! > Date() && day.meals.count != 0 {
                return "until \(formatter.date(from: day.date)!.dayOfWeek)"
            }
        }

        return "Indefinitely"
    }

    var isMainDiningTimes: Bool {
        return (currentMealType == "Breakfast" || currentMealType == "Lunch" || currentMealType == "Dinner")
    }

    // MARK: - Formatted Hours
    var humanFormattedHoursStringForToday: String {
        guard mealsToday != [] else { return "" }
        return formattedHoursStringFor(Date())
    }

    func formattedHoursStringFor(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dateString = dateFormatter.string(from: date)
        return formattedHoursStringFor(dateString)
    }

    func formattedHoursStringFor(_ dateString: String) -> String {
        guard let meals = self.days.first(where: { day in
            day.date == dateString
        })?.meals else { return "" }

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
            if m.starttime.minutes == 0 {
                formatter.dateFormat = moreThanOneMeal ? "h" : "h"
            } else {
                formatter.dateFormat = moreThanOneMeal ? "h:mm" : "h:mm"
            }
            let open = formatter.string(from: m.starttime)

            if m.endtime.minutes == 0 {
                formatter.dateFormat = moreThanOneMeal ? "h" : "ha"
            } else {
                formatter.dateFormat = moreThanOneMeal ? "h:mm" : "h:mma"
            }
            let close = formatter.string(from: m.endtime)

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
        guard mealsToday != [] else { return [] }
        return formattedHoursArrayFor(Date())
    }

    func formattedHoursArrayFor(_ date: Date) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        

        let dateString = dateFormatter.string(from: date)
        return formattedHoursArrayFor(dateString)
    }

    func formattedHoursArrayFor(_ dateString: String) -> [String] {

        var formattedHoursArray = [String]()

        guard let meals = self.days.first(where: { day in
            day.date == dateString
        })?.meals else { return [] }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "h:mm"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"

        let moreThanOneMeal = meals.count > 1
        
        let sortedMeals = meals.sorted(by: { el1, el2 in
            return el1.starttime < el2.starttime
        })

        for m in sortedMeals {
            if m.starttime.minutes == 0 {
                formatter.dateFormat = moreThanOneMeal ? "h" : "h"
            } else {
                formatter.dateFormat = moreThanOneMeal ? "h:mm" : "h:mm"
            }
            let open = formatter.string(from: m.starttime)

            if m.endtime.minutes == 0 {
                formatter.dateFormat = moreThanOneMeal ? "h" : "ha"
            } else {
                formatter.dateFormat = moreThanOneMeal ? "h:mm" : "h:mma"
            }
            let close = formatter.string(from: m.endtime)

            formattedHoursArray.append("\(open) - \(close)")
        }

        return formattedHoursArray
    }

    var statusString: String {
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
                    return "\(nextMeal.label) \(Date().humanReadableDistanceFrom(nextMeal.starttime))"
                default:
                    return "Opens \(Date().humanReadableDistanceFrom(nextMeal.starttime))"
                }
            } else {
                return "Closed \(nextOpenedDayOfTheWeek)"
            }
        } else {
            return "Closed \(nextOpenedDayOfTheWeek)"
        }
    }

    var statusImageString: String {
        if hasMealsToday {
            if isOpen {
                return "circle.fill"
            } else if nextMeal != nil {
                return "pause.circle.fill"
            } else {
                return "xmark.circle.fill"
            }
        } else {
            return "xmark.circle.fill"
        }
    }
}

// MARK: - Meal
public extension Meal {
    var isCurrentlyServing: Bool {
        let now = Date()
        return (self.starttime <= now && self.endtime > now)
    }

    var isLight: Bool {
        return self.label.contains("Light")
    }
}
