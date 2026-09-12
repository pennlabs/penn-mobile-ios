//
//  LaundryHallUsageResponse.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

public struct LaundryHallUsageResponse: Codable, Hashable, Sendable {
    public let rooms: [LaundryRoom]
}
