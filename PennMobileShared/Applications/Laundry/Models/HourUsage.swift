//
//  HourUsage.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

public struct HourUsage: Identifiable, Hashable, Sendable {
    public let id: Int
    public let hour: Int
    public let normalizedLoad: Double
}
