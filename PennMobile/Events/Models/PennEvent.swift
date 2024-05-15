//
//  PennEvent.swift
//  PennMobile
//
//  Created by Jacky on 3/29/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

// for decoding api
struct PennEvent: Decodable {
    var eventType: String?
    var name: String?
    var description: String?
    var location: String?
    var imageUrl: String?
    var start: String?
    var end: String?
    var email: String?
    var website: String?
    // penn clubs api
    var startTime: String?
    var endTime: String?
    
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
        // penn clubs api
        case startTime = "start_time"
        case endTime = "end_time"
    }
}
