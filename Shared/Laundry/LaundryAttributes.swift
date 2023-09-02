//
//  LaundryAttributes.swift
//  PennMobile
//
//  Created by Anthony Li on 10/16/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import ActivityKit
import Foundation

struct LaundryAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {}
    
    var machine: LaundryMachine
    var dateComplete: Date
}
