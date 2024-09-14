//
//  PennEventsAPIManager.swift
//  PennMobile
//
//  Created by Jacky on 3/29/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

// api manager for new penn events
class PennEventsAPIManager {
    static let shared = PennEventsAPIManager()

    private let pennMobileUrl = "https://pennmobile.org/api/penndata/events/"
    private let pennClubsUrl = "https://pennclubs.com/api/events/"

    // fetch both penn mobile and penn club events
    func fetchAllEvents() async throws -> [PennEvent] {
        async let mobileEvents = fetchEvents(from: pennMobileUrl, tag: "Mobile")
        async let clubEvents = fetchEvents(from: pennClubsUrl, tag: "Clubs")

        do {
    //            let allEvents = try await mobileEvents + clubEvents
            let allEvents = try await mobileEvents
            return allEvents
        } catch {
            throw error
        }
    }


    // generic fetch events helper
    func fetchEvents(from urlString: String, tag: String) async throws -> [PennEvent] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        // data fetching
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        var events = try decoder.decode([PennEvent].self, from: data)

        if tag == "Clubs" {
            events = events.map { event in
                var modifiedEvent = event
                modifiedEvent.eventType = "CLUBS"
                return modifiedEvent
            }
        }

        return events
    }
}
