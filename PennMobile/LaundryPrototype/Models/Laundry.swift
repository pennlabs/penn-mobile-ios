//
//  Laundry.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

struct LaundryHallInfo: Codable, Hashable {
    let name: String
    let hallId: Int
    let location: String
}

struct LaundryHallUsageResponse: Codable, Hashable {
    let rooms: [LaundryRoom]
}

struct LaundryRoom: Codable, Hashable {
    let machines: Machines
    let hallName: String
    let location: String
    let id: Int
    let usageData: UsageData
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
}

struct MachineDetail: Codable, Hashable {
    let id: String
    let type: MachineType
    let status: Status
    let timeRemaining: Int
    
    enum MachineType: String, Codable {
        case washer, dryer
    }
    
    enum Status: String, Codable {
        case available = "AVAILABLE"
        case complete = "COMPLETE"
        case inUse = "IN_USE"
        case error = "ERROR"
        case networkError = "NETWORK_ERROR"
        case unavailable = "UNAVAILABLE"
        case unknown
        
        func imageName(for type: MachineType) -> String {
            switch self {
            case .available, .complete:
                return type == .washer ? "washer_open" : "dryer_open"
            case .inUse:
                return type == .washer ? "washer_busy" : "dryer_busy"
            case .error, .networkError, .unavailable, .unknown:
                return type == .washer ? "washer_broken" : "dryer_broken"
            }
        }
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
    
    func normalizedHourlyUsage() -> [HourUsage] {
        // Get the hours (0-26)
        let hours = Set(washerData.keys.compactMap { Int($0) })
            .union(dryerData.keys.compactMap { Int($0) })
            .sorted()
        
        // Combine the usages from each hour
        let combined: [(hour: Int, load: Double)] = hours.map { hour in
            let key = String(hour)
            let washer = washerData[key] ?? 0
            let dryer = dryerData[key] ?? 0
            return (hour, washer + dryer)
        }
        
        // Find range for normalization
        guard let maxVal = combined.map({ $0.load }).max(),
              let minVal = combined.map({ $0.load }).min() else { return [] }
        
        // Base case when flat line
        if maxVal == minVal {
            return combined.map { HourUsage(id: $0.hour, hour: $0.hour, normalizedLoad: 0.01) }
        }
        
        // Otherwise return normalized between 0 and 1
        return combined.map { point in
            let normalized = (maxVal - point.load) / (maxVal - minVal)
            return HourUsage(id: point.hour, hour: point.hour, normalizedLoad: normalized)
        }
    }
}

struct HourUsage: Identifiable, Hashable {
    let id: Int
    let hour: Int
    let normalizedLoad: Double
}
