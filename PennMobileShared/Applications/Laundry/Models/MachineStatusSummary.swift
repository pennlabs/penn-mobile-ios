//
//  MachineStatusSummary.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

public struct MachineStatusSummary: Codable, Hashable, Sendable {
    public let open: Int
    public let running: Int
    public let outOfOrder: Int
    public let offline: Int
    public let timeRemaining: [Int]
}
