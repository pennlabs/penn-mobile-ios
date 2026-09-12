//
//  DiningPreferences.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

public struct DiningPreferences: Codable, Sendable {
    public let preferences: [DiningVenuePreference]
}
