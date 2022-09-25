//
//  NotificationsSetting.swift
//  PennMobile
//
//  Created by Raunaq Singh on 9/25/22.
//  Copyright © 2022 PennLabs. All rights reserved.
//

struct NotificationSetting: Codable, Identifiable {
    let id: String
    var enabled: Bool

    enum CodingKeys: String, CodingKey {
        case enabled
        case id = "service"
    }

    // Options actually shown to user
    static let visibleOptions: Set<String> = ["LAUNDRY", "UNIVERSITY", "DINING", "GSR_BOOKING", "PENN_MOBILE"]

    var title: String? {
        switch id {
        case "LAUNDRY":
            return "Laundry notifications"
        case "UNIVERSITY":
            return "University notifications"
        case "DINING":
            return "Dining balance notifications"
        case "GSR_BOOKING":
            return "GSR booking notifications"
        case "PENN_MOBILE":
            return "App update notifications"
        case "PENN_COURSE_REVIEW":
            return ""
        case "PENN_COURSE_PLAN":
            return ""
        case "PENN_COURSE_ALERT":
            return ""
        case "OHQ":
            return ""
        case "PENN_BASICS":
            return ""
        case "PENN_CLUBS":
            return ""
        case "CFA":
            return ""
        default:
            return nil
        }
    }

    var description: String? {
        switch id {
        case "LAUNDRY":
            return "Notifications about laundry cycles. Tap on a laundry machine with time remaining to set the notification."
        case "UNIVERSITY":
            return "Notifications about significant university events."
        case "DINING":
            return "Receive monthly updates containing a summary of the past month's dining dollar and swipe use."
        case "GSR_BOOKING":
            return "Notifications about your upcoming GSR bookings, sent 10 minutes from the start of booking. Includes the room and duration. Long press the notification to cancel your booking."
        case "PENN_MOBILE":
            return "Get notified about major updates to Penn Mobile."
        case "PENN_COURSE_REVIEW":
            return ""
        case "PENN_COURSE_PLAN":
            return ""
        case "PENN_COURSE_ALERT":
            return ""
        case "OHQ":
            return ""
        case "PENN_BASICS":
            return ""
        case "PENN_CLUBS":
            return ""
        case "CFA":
            return ""
        default:
            return nil
        }
    }
}
