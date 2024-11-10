//
//  Day.swift
//  PennMobileShared
//
//  Created by Anthony Li on 2/9/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

public struct Day: Hashable, Codable, Comparable, Sendable {
    public var year: Int
    public var month: Int
    public var day: Int
    
    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
    
    public init(date: Date = Date()) {
        self.init(
            year: Calendar.autoupdatingCurrent.component(.year, from: date),
            month: Calendar.autoupdatingCurrent.component(.month, from: date),
            day: Calendar.autoupdatingCurrent.component(.day, from: date)
        )
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        let parts = string.split(separator: "-")
        
        guard parts.count == 3, let year = Int(parts[0]), let month = Int(parts[1]), let day = Int(parts[2]) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid format for Day")
        }
        
        self.year = year
        self.month = month
        self.day = day
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(format: "%d-%02d-%02d", year, month, day))
    }
    
    public var date: Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        return Calendar.autoupdatingCurrent.date(from: components)
    }
    
    public static func < (lhs: Day, rhs: Day) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        } else if lhs.month != rhs.month {
            return lhs.month < rhs.month
        } else {
            return lhs.day < rhs.day
        }
    }
}
