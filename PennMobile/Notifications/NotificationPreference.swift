//
//  NotificationPreference.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

typealias NotificationPreferences = Dictionary<NotificationOption, Bool>

enum NotificationOption: String, Codable {
    case pennMobileUpdateAnnouncement
    case upcomingStudyRoomReminder
    case laundryMachineCycleComplete
    case collegeHouseAnnouncement
    case universityEventAnnouncement
    case dailyMenuNotification
    case dailyMenuNotificationBreakfast
    case dailyMenuNotificationLunch
    case dailyMenuNotificationDinner
    
    // Options to be actually shown to the user
    static let visibleOptions: [NotificationOption] = [
        .upcomingStudyRoomReminder, .laundryMachineCycleComplete, .universityEventAnnouncement, .pennMobileUpdateAnnouncement
    ]
    
    var cellTitle: String? {
        switch self {
        case .upcomingStudyRoomReminder: return "GSR booking notifications"
        case .laundryMachineCycleComplete: return "Laundry notifications"
        case .universityEventAnnouncement: return "University notifications"
        case .pennMobileUpdateAnnouncement: return "App update notifications"
        default: return nil
        }
    }
    
    var cellFooterDescription: String? {
        switch self {
        case .upcomingStudyRoomReminder: return "Notifications about your upcoming GSR bookings, sent 10 minutes from the start of booking. Includes the room and duration. Long press the notification to cancel your booking."
        case .laundryMachineCycleComplete:
            return "Notifications about laundry cycles. Tap on a laundry machine with time remaining to set the notification."
        case .universityEventAnnouncement: return "Notifications about significant university events."
        case .pennMobileUpdateAnnouncement: return "Get notified about major updates to Penn Mobile."
        default: return nil
        }
    }
}
