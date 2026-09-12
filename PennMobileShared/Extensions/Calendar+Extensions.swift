//
//  Calendar+Extensions.swift
//  PennMobileShared
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import Foundation

public extension Calendar {
    static let nyc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .enUS
        calendar.timeZone = .nyc
        return calendar
    }()
    
    static var isAprilFools: Bool {
        let components = Calendar.autoupdatingCurrent.dateComponents(in: .autoupdatingCurrent, from: Date())
        return components.month == 4 && components.day == 1
    }
}
