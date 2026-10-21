//
//  CalendarEvent.swift
//  PennMobile
//
//  Created by Marta García Ferreiro on 11/16/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

public struct CalendarEvent: Codable, Equatable, Sendable {
    public let event: String
    public let date: String

    public init(event: String, date: String) {
        self.event = event
        self.date = date
    }

    public static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        return lhs.event == rhs.event
    }
}
