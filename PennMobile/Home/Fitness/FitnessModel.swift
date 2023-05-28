//
//  FacilityModel.swift
//  PennMobile
//
//  Created by Jordan H on 4/7/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import Foundation

struct FitnessRoom: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let last_updated: Date // "2023-04-07T12:32:34-04:00"
    let count: Int
    let capacity: Double
    let open: [String]
    let close: [String]
    var data: FitnessRoomData?
}

struct FitnessRoomData: Codable, Equatable {
    let name: String
    let start: String
    let end: String
    let usage: [String: Double]
    
    enum CodingKeys: String, CodingKey {
        case name = "room_name"
        case start = "start_date"
        case end = "end_date"
        case usage
    }
    
    var usageHours: [DataHour] {
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

struct DataHour: Identifiable {
    let date: Date
    let value: Double
    var id: Date {date}
}
