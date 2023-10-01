//
//  EventsAPI.swift
//  PennMobile
//
//  Created by Samantha Su on 10/1/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import SwiftyJSON
import Foundation
import PennSharedCode

class EventsAPI: Requestable {
    static let instance = EventsAPI()

    let eventsUrl = "https://penntoday.upenn.edu/events-feed?_format=json"

    func fetchEvents(_ completion: @escaping (_ result: Result<[PennEvents], NetworkingError>) -> Void) {
        getRequestData(url: eventsUrl) { (data, _, statusCode) in
            if statusCode == nil {
                return completion(.failure(.noInternet))
            }

            if statusCode != 200 {
                return completion(.failure(.serverError))
            }

            guard let data = data else { return completion(.failure(.other)) }

            let decoder = JSONDecoder()

            let formatter = DateFormatter()
           formatter.locale = Locale(identifier: "en_US_POSIX")
           formatter.timeZone = TimeZone(abbreviation: "EST")
           formatter.dateFormat = "MM/dd/yyyy"

            decoder.dateDecodingStrategy = .formatted(formatter)

            if let events = try? decoder.decode([PennEvents].self, from: data) {
                self.saveToCache(events)
                completion(.success(events))
            } else {
                completion(.failure(.serverError))
            }
        }
    }

    // MARK: - Cache Methods
    func saveToCache(_ response: [PennEvents]) {
        Storage.store(response, to: .caches, as: PennEvents.directory)
    }
}
