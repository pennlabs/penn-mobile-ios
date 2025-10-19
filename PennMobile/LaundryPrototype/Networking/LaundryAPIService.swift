
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
final class LaundryAPIService: ObservableObject {
    
    let laundryUsageURL: URL = URL(string: "https://pennmobile.org/api/laundry/rooms/")!
    let laundryIdURL: URL = URL(string: "https://pennmobile.org/api/laundry/halls/ids")!
    let laundryStatusURL: URL = URL(string: "https://pennmobile.org/api/laundry/status")!
    
    func getLaundryAPIStatus() async throws -> LaundryAPIStatus {
        let (data, _) = try await URLSession.shared.data(from: laundryStatusURL)
        let decoded = try JSONDecoder().decode(LaundryAPIStatus.self, from: data)
        return decoded
    }
    
    func getLaundryHallIDData() async throws -> [LaundryHallID] {
        let (data, _) = try await URLSession.shared.data(from: laundryIdURL)
        let decoded = try JSONDecoder().decode([LaundryHallID].self, from: data)
        return decoded
    }
    
    func getLaundryHallUsage(for hall_id: Int) async throws -> LaundryHallUsage {
        let url: URL = URL(string: "https://pennmobile.org/api/laundry/rooms/\(hall_id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(LaundryHallUsage.self, from: data)
        return decoded
    }
}

#Playground("getLaundryAPIStatus") {
    do {
        let data = try await LaundryAPIService().getLaundryAPIStatus()
        print(data)
    } catch {
        print(error)
    }
}

#Playground("getLaundryHallIDData") {
    do {
        let data = try await LaundryAPIService().getLaundryHallIDData()
        print(data)
    } catch {
        print(error)
    }
}

#Playground("getLaundryHallUsage") {
    do {
        let data = try await LaundryAPIService().getLaundryHallIDData()
        for hall in data {
            do {
                let usageData = try await LaundryAPIService().getLaundryHallUsage(for: hall.hallID)
                print(usageData)
            } catch {
                print(error)
            }
        }
    } catch {
        print(error)
    }
}
