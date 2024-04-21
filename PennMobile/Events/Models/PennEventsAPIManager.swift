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
    func fetchAllEvents(completion: @escaping ([PennEvent]?, Error?) -> Void) {
        let group = DispatchGroup()

        var allEvents: [PennEvent] = []
        var anyError: Error?

        // fetch reg penn mobile backend events
        group.enter()
        fetchEvents(from: pennMobileUrl, tag: "Mobile") { events, error in
            if let events = events {
                allEvents += events
            } else {
                anyError = error
            }
            group.leave()
        }

        // fetch penn clubs events
//        group.enter()
//        fetchEvents(from: pennClubsUrl, tag: "Clubs") { events, error in
//            if let events = events {
//                allEvents += events.map { event in
//                    var modifiedEvent = event
//                    modifiedEvent.eventType = "CLUBS"
//                    return modifiedEvent
//                }
//            } else {
//                anyError = error
//            }
//            group.leave()
//        }

        group.notify(queue: .main) {
            completion(anyError == nil ? allEvents : nil, anyError)
        }
    }

    // generic fetch events helper
    func fetchEvents(from urlString: String, tag: String, completion: @escaping ([PennEvent]?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 404, userInfo: nil))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }

            do {
                let decoder = JSONDecoder()
                var events = try decoder.decode([PennEvent].self, from: data)
                if tag == "Clubs" {
                    events = events.map { event in
                        var modifiedEvent = event
                        modifiedEvent.eventType = "CLUBS"
                        return modifiedEvent
                    }
                }
                completion(events, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}
