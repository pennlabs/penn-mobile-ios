//
//  LaundryAttributes.swift
//  PennMobile
//
//  Created by Anthony Li on 10/16/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation
#if canImport(ActivityKit)
import ActivityKit
#endif

public struct LaundryAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public init() {}
    }
    
    public var machine: LaundryMachine
    public var dateComplete: Date
    
    public init(machine: LaundryMachine, dateComplete: Date) {
        self.machine = machine
        self.dateComplete = dateComplete
    }
}
