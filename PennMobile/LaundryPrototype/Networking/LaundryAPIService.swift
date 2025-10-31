
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
class LaundryAPIService {
    
    private static let laundryIdURL: URL = URL(string: "https://pennmobile.org/api/laundry/halls/ids")!
    private static let laundryUsageURL: URL = URL(string: "https://pennmobile.org/api/laundry/rooms/")!
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    static func getLaundryHallIdData() async throws -> [LaundryHallInfo] {
        let (data, _) = try await URLSession.shared.data(from: laundryIdURL)
        let decoded = try decoder.decode([LaundryHallInfo].self, from: data)
        return decoded
    }
    
    static func getLaundryHallUsage(for hall_id: Int) async throws -> LaundryHallUsageResponse {
        let url: URL = laundryUsageURL.appending(path: String(hall_id), directoryHint: .notDirectory)
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try decoder.decode(LaundryHallUsageResponse.self, from: data)
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
