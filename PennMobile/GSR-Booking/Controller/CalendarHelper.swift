//
//  CalendarHelper.swift
//  PennMobile
//
//  Created by Ximing Luo on 3/14/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import EventKit
import SwiftUI

enum CalendarError: Error {
    case accessDenied
    case saveFailed(Error)
}

struct CalendarHelper {
    static func addToCalendar(
        title: String,
        location: String,
        start: Date,
        end: Date
    ) async throws {
        let eventStore = EKEventStore()

        let granted = try await eventStore.requestWriteOnlyAccessToEvents()
        guard granted else {
            throw CalendarError.accessDenied
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.location = location
        event.startDate = start
        event.endDate = end
        event.notes = "Created by Penn Mobile"
        event.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            throw CalendarError.saveFailed(error)
        }
    }
}
