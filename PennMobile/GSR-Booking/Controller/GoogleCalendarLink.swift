//
//  GoogleCalendarLink.swift
//  PennMobile
//
//  Created by Ximing Luo on 3/14/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation

enum GoogleCalendarLink {
    static func makeURL(title: String, location: String, start: Date, end: Date) -> URL? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end)

        var components = URLComponents(string: "https://calendar.google.com/calendar/render")
        components?.queryItems = [
            URLQueryItem(name: "action", value: "TEMPLATE"),
            URLQueryItem(name: "text", value: title),
            URLQueryItem(name: "location", value: location),
            URLQueryItem(name: "dates", value: "\(startStr)/\(endStr)")
        ]
        return components?.url
    }
}
