//
//  Laundry.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

struct LaundryHallId: Codable, Hashable {
    let name: String
    let hallId: Int
    let location: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case hallId = "hall_id"
        case location
    }
}

struct LaundryHallUsage: Codable, Hashable {
    let rooms: [LaundryRoom]
}

struct LaundryRoom: Codable, Hashable {
    let machines: Machines
    let hallName: String
    let location: String
    let id: Int
    let usageData: UsageData

    enum CodingKeys: String, CodingKey {
        case machines
        case hallName = "hall_name"
        case location
        case id
        case usageData = "usage_data"
    }
}

struct Machines: Codable, Hashable {
    let washers: MachineStatus
    let dryers: MachineStatus
    let details: [MachineDetail]
}

struct MachineStatus: Codable, Hashable {
    let open: Int
    let running: Int
    let outOfOrder: Int
    let offline: Int
    let timeRemaining: [Int]

    enum CodingKeys: String, CodingKey {
        case open, running
        case outOfOrder = "out_of_order"
        case offline
        case timeRemaining = "time_remaining"
    }
}

struct MachineDetail: Codable, Hashable {
    let id: String
    let type: String
    let status: String
    let timeRemaining: Int

    enum CodingKeys: String, CodingKey {
        case id, type, status
        case timeRemaining = "time_remaining"
    }
}

struct UsageData: Codable, Hashable {
    let hallName: String
    let location: String
    let dayOfWeek: String
    let startDate: String
    let endDate: String
    let washerData: [String: Double]
    let dryerData: [String: Double]
    let totalNumberOfWashers: Int
    let totalNumberOfDryers: Int

    enum CodingKeys: String, CodingKey {
        case hallName = "hall_name"
        case location
        case dayOfWeek = "day_of_week"
        case startDate = "start_date"
        case endDate = "end_date"
        case washerData = "washer_data"
        case dryerData = "dryer_data"
        case totalNumberOfWashers = "total_number_of_washers"
        case totalNumberOfDryers = "total_number_of_dryers"
    }
}
