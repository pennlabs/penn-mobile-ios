//
//  GSRAvailability.swift
//  PennMobile
//
//  Created by Khoi Dinh on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation

class GSRAvailability {
    static func getGSRSCurrentlyOpen(location: GSRLocation) async throws -> Int {
        let avail = try await GSRNetworkManager.getAvailability(for: location, startDate: Date.now, endDate: Date.now)
        let interval = 30 * 60 // 30 mins * 60 seconds
        let dateNextInterval = Date().addingTimeInterval(TimeInterval(interval))
        // filter by start date less than 30 minutes from now
        var count = 0
        for room in avail {
            if let firstSlot = room.availability.min(by: {$0.startTime < $1.startTime}) {
                count += firstSlot.startTime <= dateNextInterval ? 1 : 0
            }
        }
        return count
    }
}
