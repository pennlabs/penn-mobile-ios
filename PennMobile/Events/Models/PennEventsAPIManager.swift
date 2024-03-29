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

    private let baseUrlString = "https://pennmobile.org/api/penndata/events/"

    func fetchEvents(completion: @escaping ([PennEvent]?, Error?) -> Void) {
        guard let url = URL(string: baseUrlString) else {
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
                let events = try decoder.decode([PennEvent].self, from: data)
                completion(events, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}

