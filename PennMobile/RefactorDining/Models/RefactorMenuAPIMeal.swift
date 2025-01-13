//
//  RefactorMenuAPIMeal.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/13/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import Foundation

//NOTE: This model is used as in intermediary as the meal data is processed. Its data is used internally only in the scope of the *Menu* endpoint.
//      See the DiningHall.swift for the final model.
struct RefactorMenuAPIMeal: Codable, Comparable {
    
    // same as DiningMeal.swift comparable
    static func < (lhs: RefactorMenuAPIMeal, rhs: RefactorMenuAPIMeal) -> Bool {
        if (lhs.venue.venueId == rhs.venue.venueId) {
            return lhs.startTime < rhs.startTime
        }
        
        return lhs.venue.venueId < rhs.venue.venueId
    }
    static func == (lhs: RefactorMenuAPIMeal, rhs: RefactorMenuAPIMeal) -> Bool {
        lhs.venue.venueId == rhs.venue.venueId && (lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime)
    }
    
    
    let id: Int
    let venue: RefactorMenuAPIVenue
    let stations: [RefactorDiningStation]
    let date: Date
    let startTime: Date
    let endTime: Date
    let service: String
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.venue = try container.decode(RefactorMenuAPIVenue.self, forKey: .venue)
        self.stations = try container.decode([RefactorDiningStation].self, forKey: .stations)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let dateStr = try? container.decode(String.self, forKey: .date), let date = formatter.date(from: dateStr) else {
            throw DecodingError.valueNotFound(Date.self, DecodingError.Context(codingPath: [], debugDescription: "Could not decode date"))
        }
        self.date = date
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let startTimeStr = try? container.decode(String.self, forKey: .startTime), let startTime = formatter.date(from: startTimeStr) else {
            throw DecodingError.valueNotFound(Date.self, DecodingError.Context(codingPath: [], debugDescription: "Could not decode start time"))
        }
        self.startTime = startTime
        
        guard let endTimeStr = try? container.decode(String.self, forKey: .endTime), let endTime = formatter.date(from: endTimeStr) else {
            throw DecodingError.valueNotFound(Date.self, DecodingError.Context(codingPath: [], debugDescription: "Could not decode end time"))
        }
        self.endTime = endTime
        self.service = try container.decode(String.self, forKey: .service)
    }
    
    
    
}

struct RefactorMenuAPIVenue: Codable, Equatable {
    let venueId: Int
    let name: String
    let imageUrl: String
    
    static func == (lhs: RefactorMenuAPIVenue, rhs: RefactorMenuAPIVenue) -> Bool {
        lhs.venueId == rhs.venueId
    }
}
