
//
//  LaundryAPIService.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation
import Playgrounds

@MainActor
final class LaundryAPIService {
    
    static let laundryUsageURL: URL = URL(string: "https://pennmobile.org/api/laundry/rooms/")!
    static let laundryIdURL: URL = URL(string: "https://pennmobile.org/api/laundry/halls/ids")!
    
    static func getLaundryHallIdData() async throws -> [LaundryHallId] {
        let (data, _) = try await URLSession.shared.data(from: laundryIdURL)
        let decoded = try JSONDecoder().decode([LaundryHallId].self, from: data)
        return decoded
    }
    
    static func getLaundryHallUsage(for hall_id: Int) async throws -> LaundryHallUsage {
        let url: URL = URL(string: "https://pennmobile.org/api/laundry/rooms/\(hall_id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(LaundryHallUsage.self, from: data)
        return decoded
    }
}

#Playground("getLaundryHallIdData") {
    do {
        let data = try await LaundryAPIService.getLaundryHallIdData()
        print(data)
    } catch {
        print(error)
    }
}

#Playground("getLaundryHallUsage") {
    do {
        let data = try await LaundryAPIService.getLaundryHallIdData()
        for hall in data {
            do {
                let usageData = try await LaundryAPIService.getLaundryHallUsage(for: hall.hallId)
                print(usageData)
            } catch {
                print(error)
            }
        }
    } catch {
        print(error)
    }
}
