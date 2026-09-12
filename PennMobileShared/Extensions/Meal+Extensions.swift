//
//  Meal+Extensions.swift
//  PennMobile
//
//  Created by Dominic Holmes on 10/21/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

public extension Meal {
    var isCurrentlyServing: Bool {
        let now = Date()
        return (self.starttime <= now && self.endtime > now)
    }

    var isLight: Bool {
        return self.label.contains("Light")
    }
}
