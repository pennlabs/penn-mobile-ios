//
//  GoogleCalendarLink.swift
//  PennMobile
//
//  Created by Ximing Luo on 3/14/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import Foundation

struct GoogleCalendarLink {
    static func makeURL(title: String, location: String, start: Date, end: Date) -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let startStr = dateFormatter.string(from: start)
        let endStr = dateFormatter.string(from: end)

        let escapedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Event"
        let escapedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let urlString = "https://calendar.google.com/calendar/render?action=TEMPLATE&text=\(escapedTitle)&location=\(escapedLocation)&dates=\(startStr)/\(endStr)"

        return URL(string: urlString)
    }
}
