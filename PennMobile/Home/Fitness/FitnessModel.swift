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
    let open: Date
    let close: Date
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
}
