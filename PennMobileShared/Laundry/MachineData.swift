//
//  MachineData.swift
//  PennMobileShared
//
//  Created by Nathan Aronson on 11/23/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation
#if canImport(AlarmKit)
import AlarmKit
#endif
#if canImport(ActivityKit)
import ActivityKit
#endif

public struct MachineData: AlarmMetadata, ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public init() {}
    }
    
    public let createdAt: Date
    public let hallName: String
    public let machine: MachineDetail
    
    public init(hallName: String, machine: MachineDetail) {
        self.createdAt = Date.now
        self.hallName = hallName
        self.machine = machine
    }
}
