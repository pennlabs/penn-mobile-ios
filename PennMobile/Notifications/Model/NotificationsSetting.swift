//
//  NotificationsSetting.swift
//  PennMobile
//
//  Created by Raunaq Singh on 9/25/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

import Foundation

struct NotificationSetting: Codable, Identifiable {
    let id: Int
    let service: NotificationType
    var enabled: Bool
}

enum NotificationType: String, Codable {
    case LAUNDRY
    case UNIVERSITY
    case DINING
    case GSR_BOOKING
    case PENN_MOBILE
    case PENN_COURSE_REVIEW
    case PENN_COURSE_PLAN
    case PENN_COURSE_ALERT
    case OHQ
    case PENN_BASICS
    case PENN_CLUBS
    case CFA

    // Options to be actually shown to the user
    static let visibleOptions: Set<NotificationType> = [.LAUNDRY, .UNIVERSITY, .DINING, .GSR_BOOKING, .PENN_MOBILE]

    var title: String {
        switch self {
        case .LAUNDRY: return "Laundry notifications"
        case .UNIVERSITY: return "University notifications"
        case .DINING: return "Dining balance notifications"
        case .GSR_BOOKING: return "GSR booking notifications"
        case .PENN_MOBILE: return "App update notifications"
        default:
            return "N/A"
        }
    }

    var description: String {
        switch self {
        case .LAUNDRY:
            return "Notifications about laundry cycles. Tap on a laundry machine with time remaining to set the notification."
        case .UNIVERSITY:
            return "Notifications about significant university events."
        case .DINING:
            return "Receive monthly updates containing a summary of the past month's dining dollar and swipe use."
        case .GSR_BOOKING:
            return "Notifications about your upcoming GSR bookings, sent 10 minutes from the start of booking. Includes the room and duration. Long press the notification to cancel your booking."
        case .PENN_MOBILE:
            return "Get notified about major updates to Penn Mobile."
        default:
            return "N/A"
        }
    }
    
    var actions: [UNNotificationAction] {
        switch self {
        case .GSR_BOOKING:
            let cancelGSRBookingAction = UNNotificationAction(identifier: NotificationAction.cancelGSRBooking.rawValue, title: "Cancel Booking", options: [.foreground])
            let shareGSRBookingAction = UNNotificationAction(identifier: NotificationAction.shareGSRBooking.rawValue, title: "Share", options: [.foreground])
            return [cancelGSRBookingAction, shareGSRBookingAction]
        default:
            return []
        }
    }
    
    var category: UNNotificationCategory {
        switch self {
        case .GSR_BOOKING:
            return UNNotificationCategory(
                identifier: NotificationType.GSR_BOOKING.rawValue,
                actions: NotificationType.GSR_BOOKING.actions,
                intentIdentifiers: [],
                hiddenPreviewsBodyPlaceholder: "Upcoming GSR",
                options: []
            )
        default:
            return UNNotificationCategory(identifier: "", actions: [], intentIdentifiers: [])
        }
    }
}

enum NotificationAction: String, Codable {
    case shareGSRBooking
    case cancelGSRBooking
    
}
