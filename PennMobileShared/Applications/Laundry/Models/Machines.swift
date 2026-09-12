//
//  Machines.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

public struct Machines: Codable, Hashable, Sendable {
    public let washers: MachineStatusSummary
    public let dryers: MachineStatusSummary
    public let details: [MachineDetail]
}
