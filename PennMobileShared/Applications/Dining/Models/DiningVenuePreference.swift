//
//  DiningVenuePreference.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

public struct DiningVenuePreference: Codable, Sendable {
    public let venueId: Int

    public enum CodingKeys: String, CodingKey {
        case venueId = "venue_id"
    }
}
