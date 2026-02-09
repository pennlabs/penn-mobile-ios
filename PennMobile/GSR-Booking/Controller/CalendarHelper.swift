//
//  CalendarHelper.swift
//  PennMobile
//
//  Created by Ximing Luo on 3/14/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import EventKit
import SwiftUI

struct CalendarHelper {
    static func addToCalendar(
        title: String,
        location: String,
        start: Date,
        end: Date,
        completion: @escaping (Bool) -> Void
    ) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            if granted, error == nil {
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.location = location
                event.startDate = start
                event.endDate = end
                event.notes = "Created by Penn Mobile"
                event.calendar = eventStore.defaultCalendarForNewEvents

                do {
                    try eventStore.save(event, span: .thisEvent)
                    print("Event added to calendar")
                    completion(true)
                } catch {
                    print("Failed to save event: \(error)")
                    completion(false)
                }
            } else {
                print("Calendar access not granted or error: \(String(describing: error))")
                completion(false)
            }
        }
    }
}
