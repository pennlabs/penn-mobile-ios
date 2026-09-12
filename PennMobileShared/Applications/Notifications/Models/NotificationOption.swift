//
//  NotificationOption.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

public enum NotificationOption: String, Codable, Sendable {
    case pennMobileUpdateAnnouncement
    case upcomingStudyRoomReminder
    case diningBalanceSummary
    case laundryMachineCycleComplete
    case collegeHouseAnnouncement
    case universityEventAnnouncement
    case dailyMenuNotification
    case dailyMenuNotificationBreakfast
    case dailyMenuNotificationLunch
    case dailyMenuNotificationDinner
    case pennCourseAlerts

    public static let visibleOptions: [NotificationOption] = [
        .upcomingStudyRoomReminder, .diningBalanceSummary, .pennCourseAlerts, .universityEventAnnouncement, .pennMobileUpdateAnnouncement
    ]

    public var cellTitle: String? {
        switch self {
        case .pennCourseAlerts: return "Penn Course Alerts"
        case .upcomingStudyRoomReminder: return "GSR Booking Notifications"
        case .diningBalanceSummary: return "Dining Balance Notifications"
        case .laundryMachineCycleComplete: return "Laundry Notifications"
        case .universityEventAnnouncement: return "University Notifications"
        case .pennMobileUpdateAnnouncement: return "App Update Notifications"
        default: return nil
        }
    }

    public var cellFooterDescription: String? {
        switch self {
        case .pennCourseAlerts: return "Receive notifications from Penn Course Alert."
        case .upcomingStudyRoomReminder: return "Notifications about your upcoming GSR bookings, sent 10 minutes from the start of booking. Includes the room and duration. Long press the notification to cancel your booking."
        case .laundryMachineCycleComplete:
            return "Notifications about laundry cycles. Tap on a laundry machine with time remaining to set the notification."
        case .diningBalanceSummary:
            return "Receive monthly updates containing a summary of the past month's dining dollar and swipe use."
        case .universityEventAnnouncement: return "Notifications about significant university events."
        case .pennMobileUpdateAnnouncement: return "Get notified about major updates to Penn Mobile."
        default: return nil
        }
    }

    public var defaultValue: Bool {
        return false
    }
}
