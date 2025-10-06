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
        return avail.count
    }
}
