//
//  FitnessRoomData.swift
//  PennMobile
//
//  Created by Jordan H on 4/7/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import Foundation

public struct FitnessRoomData: Codable, Equatable, Sendable {
    public let name: String
    public let start: String
    public let end: String
    public let usage: [String: Double]
    
    public enum CodingKeys: String, CodingKey {
        case name = "room_name"
        case start = "start_date"
        case end = "end_date"
        case usage
    }
    
    public var usageHours: [DataHour] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH"
        
        return usage.sorted(by: { $0.key < $1.key }).map { key, value in
            guard let date = dateFormatter.date(from: "\(end) \(key)") else {
                fatalError("Invalid date format")
            }
            return DataHour(date: date, value: value)
        }
    }
}
