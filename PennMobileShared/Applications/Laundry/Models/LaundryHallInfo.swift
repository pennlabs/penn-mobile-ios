//
//  LaundryHallInfo.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

public struct LaundryHallInfo: Codable, Hashable, Sendable {
    public let name: String
    public let hallId: Int
    public let location: String
}
