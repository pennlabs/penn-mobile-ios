//
//  UsageData.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

public struct UsageData: Codable, Hashable, Sendable {
    public let hallName: String
    public let location: String
    public let dayOfWeek: String
    public let startDate: String
    public let endDate: String
    public let washerData: [String: Double]
    public let dryerData: [String: Double]
    public let totalNumberOfWashers: Int
    public let totalNumberOfDryers: Int
    
    public func normalizedHourlyUsage() -> [HourUsage] {
        let hours = Set(washerData.keys.compactMap { Int($0) })
            .union(dryerData.keys.compactMap { Int($0) })
            .sorted()
        
        let combined: [(hour: Int, load: Double)] = hours.map { hour in
            let key = String(hour)
            let washer = washerData[key] ?? 0
            let dryer = dryerData[key] ?? 0
            return (hour, washer + dryer)
        }
        
        guard let maxVal = combined.map({ $0.load }).max(),
              let minVal = combined.map({ $0.load }).min() else { return [] }
        
        if maxVal == minVal {
            return combined.map { HourUsage(id: $0.hour, hour: $0.hour, normalizedLoad: 0.01) }
        }
        
        return combined.map { point in
            let normalized = (maxVal - point.load) / (maxVal - minVal)
            return HourUsage(id: point.hour, hour: point.hour, normalizedLoad: normalized)
        }
    }
}
