//
//  LaundryRoom.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

public struct LaundryRoom: Codable, Hashable, Sendable {
    public let machines: Machines
    public let hallName: String
    public let location: String
    public let id: Int
    public let usageData: UsageData
}
