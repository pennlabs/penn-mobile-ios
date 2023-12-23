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
    let service: NotificationPreference
    var enabled: Bool
}

enum NotificationPreference: String, Codable {
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
    static let visibleOptions: Set<NotificationPreference> = [.LAUNDRY, .UNIVERSITY, .DINING, .GSR_BOOKING, .PENN_MOBILE]

    var title: String {
        switch self {
        case .LAUNDRY: return "Laundry Notifications"
        case .UNIVERSITY: return "University Notifications"
        case .DINING: return "Dining Balance Notifications"
        case .GSR_BOOKING: return "GSR Booking Notifications"
        case .PENN_MOBILE: return "App Update Notifications"
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
}
