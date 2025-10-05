
//
//  LaundryAPIService.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation

@MainActor
final class LaundryAPIService: ObservableObject {
    
    let laundryURL: URL = URL(string: "https://pennmobile.org/api/laundry/rooms")!
    let laundryRoomURL: URL = URL(string: "https://pennmobile.org/api/laundry/halls/ids")!
    let statusURL: URL = URL(string: "https://pennmobile.org/api/laundry/status")!
        
    func getLaundryData() async throws -> [Laundry] {
        let (data, _) = try await URLSession.shared.data(from: laundryURL)
        let decoded = try JSONDecoder().decode([Laundry].self, from: data)
        return decoded
    }
}
