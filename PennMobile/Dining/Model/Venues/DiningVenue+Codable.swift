//
//  DiningVenue+Codable.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

// MARK: - Codable Dining Venue
extension DiningVenue {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case venueType = "venueType"
        case facilityURL = "facilityURL"
        case imageURL = "imageUrl"
        case meals = "dateHours"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let venueType = try container.decode(VenueType.self, forKey: .venueType)
        
        // Decode optional URLs
        var facilityURL: URL? = nil
        var imageURL: URL? = nil
        let facilityURLString = try container.decodeIfPresent(String.self, forKey: .facilityURL)
        if facilityURLString != nil {
            facilityURL = URL(string: facilityURLString!)
        }
        //let imageURLString = try container.decodeIfPresent(String.self, forKey: .imageURL)
        // TODO: Change this back to real image URLs after the api is fixed
        let imageURLString = "https://s3.us-east-2.amazonaws.com/labs.api/dining/1920-commons.jpg"
        imageURL = URL(string: imageURLString)
        //if imageURLString != nil {
            //imageURL = URL(string: imageURLString!)
        //}
        
        // Create a mapping from date string to MealsForDate for that date
        var mealsDict: Dictionary<String, MealsForDate> = .init()
        if let mealsArray = try container.decodeIfPresent(Array<MealsForDate>.self, forKey: .meals) {
            for m in mealsArray {
                mealsDict[m.date] = m
            }
        }
        
        self.init(id: id, name: name, venueType: venueType, facilityURL: facilityURL, imageURL: imageURL, meals: mealsDict)
    }
    
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "EST")
        return formatter
    }
}

// MARK: - Codable VenueType Enum
extension DiningVenue.VenueType {
    public init(from decoder: Decoder) throws {
        self = try DiningVenue.VenueType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

// MARK: - Codable MealsForDate
extension DiningVenue.MealsForDate {
    // Called by JSONDecoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decoded what is given by the API
        let dateString = try container.decode(String.self, forKey: .date)
        let codableMeals = try container.decode(Array<CodableMeal>.self, forKey: .meals)
        // Parse the API result into [Meals]
        let meals = DiningVenue.MealsForDate.decodeMeals(from: codableMeals, on: dateString)
        self.init(date: dateString, meals: meals)
    }
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case meals = "meal"
    }
    
    // Used to initially decode the meal objects from API, before parsing them into a nicer form
    struct CodableMeal: Codable {
        let open: String
        let close: String
        let type: String
    }
    
    // Gets called by JSON decoder with an array of CodableMeal objects and a date. Returns nicely formatted Meal objects, with closed Meals filtered out.
    static func decodeMeals(from codableMeals: [DiningVenue.MealsForDate.CodableMeal], on dateString: String) -> [DiningVenue.MealsForDate.Meal] {

        // Each date should be adjusted from 11:59 to 12:00
        func createMealDate(from time: String, with date: String) -> Date? {
            return Meal.dateFormatter.date(from: date + ":" + time)?.adjustedFor11_59
        }
        
        var validMeals = [DiningVenue.MealsForDate.Meal]()
        var closedMeals = [DiningVenue.MealsForDate.Meal]()
        
        for meal in codableMeals {
            // Check the open/close times are valid
            guard let openDate = createMealDate(from: meal.open, with: dateString),
                let closeDate = createMealDate(from: meal.close, with: dateString) else { continue }
            
            // Create a new meal
            let newMeal = DiningVenue.MealsForDate.Meal(open: openDate, close: closeDate, type: meal.type)
            
            // Check for meals that represent a closed state. There may be multiple.
            if newMeal.isClosedMeal {
                closedMeals.append(newMeal)
            } else {
                validMeals.append(newMeal)
            }
        }
        
        if !closedMeals.isEmpty {
            // Filter out any valid meals that overlap with an explicit "Closed" meal
            validMeals = validMeals.filter({ !$0.overlaps(with: closedMeals) })
        }
        
        return validMeals
    }
}

// MARK: - MealsForDate JSON
extension DiningVenue.MealsForDate.Meal {
    // Does one meal overlap with another
    func overlaps(with meal: DiningVenue.MealsForDate.Meal) -> Bool {
        return (meal.open >= self.open && meal.open < self.close) ||
            (self.open >= meal.open && self.open < meal.close)
    }
    
    func overlaps(with meals: [DiningVenue.MealsForDate.Meal]) -> Bool {
        meals.allSatisfy({ self.overlaps(with: $0) })
    }
    
    var isClosedMeal: Bool {
        return self.type.lowercased().contains("closed")
    }
    
    // Date format used to decode Meals
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd:HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "EST")
        return formatter
    }
}

