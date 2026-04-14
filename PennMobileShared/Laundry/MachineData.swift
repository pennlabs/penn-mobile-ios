//
//  MachineData.swift
//  PennMobileShared
//
//  Created by Nathan Aronson on 11/23/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation
import ActivityKit

#if canImport(AlarmKit)
import AlarmKit
#endif

public struct MachineData: AlarmMetadata, ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public init() {}
    }
    
    public let hallName: String
    public let machine: MachineDetail
    public let dateComplete: Date
    
    public init(hallName: String, machine: MachineDetail, dateComplete: Date) {
        self.hallName = hallName
        self.machine = machine
        self.dateComplete = dateComplete
    }
}
