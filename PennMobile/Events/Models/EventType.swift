//
//  EventType.swift
//  PennMobile
//
//  Created by Jacky on 10/9/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation


enum EventType: Decodable, Hashable {
    case houses
    case engineering
    case wharton
    case pennToday
    case ventureLab
    case clubs
    case other(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let eventTypeString = (try? container.decode(String.self).uppercased()) ?? "OTHER"

        if eventTypeString.contains("COLLEGE HOUSE") {
            self = .houses
        } else if eventTypeString.contains("ENGINEERING") {
            self = .engineering
        } else if eventTypeString.contains("WHARTON") {
            self = .wharton
        } else if eventTypeString.contains("PENN TODAY") {
            self = .pennToday
        } else if eventTypeString.contains("VENTURE LAB") {
            self = .ventureLab
        } else if eventTypeString.contains("CLUBS") {
            self = .clubs
        } else {
            self = .other(eventTypeString.capitalized)
        }
    }

    var displayName: String {
        switch self {
        case .houses:
            return "Houses"
        case .engineering:
            return "Engineering"
        case .wharton:
            return "Wharton"
        case .pennToday:
            return "Penn Today"
        case .ventureLab:
            return "Venture Lab"
        case .clubs:
            return "Clubs"
        case .other(let name):
            return name
        }
    }
}
