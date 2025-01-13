//
//  RefactorVenueAPIMeal.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/13/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//



import Foundation

//NOTE: These models are used as in intermediary as the meal data is processed. Their data are used internally only in the scope of the Venue endpoint.
//      See the DiningHall.swift for the final model.

public struct RefactorVenueAPIDiningHall: Codable, Identifiable {
    let name: String
    let address: String
    var schedule: [RefactorVenueAPIDay]
    let imageUrl: String
    public let id: Int
    
    
    enum CodingKeys: String, CodingKey {
        case name
        case address
        case schedule = "days"
        case imageUrl = "image"
        case id
    }
}

struct RefactorVenueAPIDay: Codable {
    let date: Date
    let open: Bool
    var meals: [VenueAPIMeal]
    
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let dateString = try? values.decodeIfPresent(String.self, forKey: .date) else {
            throw DecodingError.valueNotFound(Date.self, DecodingError.Context(codingPath: [CodingKeys.date], debugDescription: "Date not found."))
        }
        guard let openString = try? values.decodeIfPresent(String.self, forKey: .open) else {
            throw DecodingError.valueNotFound(String.self, DecodingError.Context(codingPath: [CodingKeys.open], debugDescription: "Status not found."))
        }
        guard let meals = try? values.decodeIfPresent([VenueAPIMeal].self, forKey: .meals) else {
            throw DecodingError.valueNotFound([VenueAPIMeal].self, DecodingError.Context(codingPath: [CodingKeys.meals], debugDescription: "Meals not found."))
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.date], debugDescription: "Invalid date format."))
        }
        self.date = date
        self.open = openString == "open"
        self.meals = meals
        
    }

    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case open = "status"
        case meals = "dayparts"
    }
}

struct VenueAPIMeal: Codable, Comparable {
    static func < (lhs: VenueAPIMeal, rhs: VenueAPIMeal) -> Bool {
        if (lhs.venueId == rhs.venueId) {
            return lhs.startTime < rhs.startTime
        }
        
        // this will put meals without a venueId at the beginning
        return lhs.venueId ?? -1 < rhs.venueId ?? -1
    }
    
    var venueId: Int?
    let startTime: Date
    let endTime: Date
    let message: String
    let label: String
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = .init(identifier: "EST")
        
        guard let startTimeStr = try? container.decode(String.self, forKey: .startTime),
              let startTime = formatter.date(from: startTimeStr) else {
            throw DecodingError.valueNotFound(String.self, DecodingError.Context(codingPath: [CodingKeys.startTime], debugDescription: "Start time invalid"))
        }
        
        guard let endTimeStr = try? container.decode(String.self, forKey: .endTime), let endTime = formatter.date(from: endTimeStr)  else {
            throw DecodingError.valueNotFound(String.self, DecodingError.Context(codingPath: [CodingKeys.endTime], debugDescription: "End time invalid"))
        }
        
        self.startTime = startTime
        self.endTime = endTime
        self.message = try container.decode(String.self, forKey: .message)
        self.label = try container.decode(String.self, forKey: .label)
    }
    
    enum CodingKeys: String, CodingKey {
        case startTime = "starttime"
        case endTime = "endtime"
        case message
        case label
    }
}

