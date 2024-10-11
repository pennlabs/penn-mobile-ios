//
//  PennEvent.swift
//  PennMobile
//
//  Created by Jacky on 3/29/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

// for decoding api
struct PennEvent: Decodable, Identifiable {
    var id = UUID()
    
    var eventType: EventType
    var name: String?
    var description: String?
    var location: String?
    var imageUrl: URL?
    var start: Date?
    var end: Date?
    var email: String?
    var website: String?
    // for penn clubs api
    var startTime: Date?
    var endTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case eventType = "event_type"
        case name
        case description
        case location
        case imageUrl = "image_url"
        case start
        case end
        case email
        case website
        case startTime = "start_time"
        case endTime = "end_time"
    }
    
    // init for previews
    init(
        id: UUID = UUID(),
        eventType: EventType = .other("Other"),
        name: String? = nil,
        description: String? = nil,
        location: String? = nil,
        imageUrl: URL? = nil,
        start: Date? = nil,
        end: Date? = nil,
        email: String? = nil,
        website: String? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil
    ) {
        self.id = id
        self.eventType = eventType
        self.name = name
        self.description = description
        self.location = location
        self.imageUrl = imageUrl
        self.start = start
        self.end = end
        self.email = email
        self.website = website
        self.startTime = startTime
        self.endTime = endTime
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventType = try container.decodeIfPresent(EventType.self, forKey: .eventType) ?? .other("Other")
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        imageUrl = try {
            if let urlString = try container.decodeIfPresent(String.self, forKey: .imageUrl) {
                return URL(string: urlString)
            }
            return nil
        }()
        email = try container.decodeIfPresent(String.self, forKey: .email)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        if let startString = try container.decodeIfPresent(String.self, forKey: .start) {
            start = dateFormatter.date(from: startString)
        }
        
        if let endString = try container.decodeIfPresent(String.self, forKey: .end) {
            end = dateFormatter.date(from: endString)
        }
        
        if let startTimeString = try container.decodeIfPresent(String.self, forKey: .startTime) {
            startTime = dateFormatter.date(from: startTimeString)
        }
        
        if let endTimeString = try container.decodeIfPresent(String.self, forKey: .endTime) {
            endTime = dateFormatter.date(from: endTimeString)
        }
    }
    
    // computed properties for formatted dates and times (ported over from PennEventViewModel)
    var formattedStartDate: String {
        guard let date = start ?? startTime else { return "No Start Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedStartTime: String {
        guard let date = start ?? startTime else { return "No Start Time" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedEndDate: String {
        guard let date = end ?? endTime else { return "No End Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedEndTime: String {
        guard let date = end ?? endTime else { return "No End Time" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var eventTitle: String {
        return name ?? "No Title"
    }
    
    var eventDescription: String {
        return description ?? "No Description"
    }
    
    var eventLocation: String {
        return location ?? "No Location"
    }
    
    var eventLink: String {
        return website ?? ""
    }
    
    var eventContactInfo: String {
        return email ?? ""
    }
    

}
