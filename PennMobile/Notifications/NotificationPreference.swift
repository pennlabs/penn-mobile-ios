//
//  NotificationPreference.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

typealias NotificationPreferences = Dictionary<String, Bool>

/*
 Notification preferences are stored in UserDefaults as a String:Bool mapping, where
 String is the unique key of the notification option (NotificationOption.rawValue) and
 Bool is whether or not the option is enabled.
 
 TO SET NOTIFICATION PREFS: use the
 UserDefaults.standard.setNotificationOption() method.
 
 After setting notification options, you should attempt to send the changes to
 the server. Do this with UserDBManager.shared.saveUserNotificationSettings()
 
 TO FETCH NOTIFICATION OPTIONS: use UserDBManager.shared.syncUserSettings() to pull
 settings from the database. Then use
 UserDefaults.standard.getPreference(forOption) to get individual preferences values
 for each option.
*/

enum NotificationOption: String, Codable {
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
    
    // Options to be actually shown to the user
    static let visibleOptions: [NotificationOption] = [
        .upcomingStudyRoomReminder, .diningBalanceSummary, .universityEventAnnouncement, .pennMobileUpdateAnnouncement
    ]
    
    var cellTitle: String? {
        switch self {
        case .upcomingStudyRoomReminder: return "GSR booking notifications"
        case .diningBalanceSummary: return "Dining balance notifications"
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
        case .diningBalanceSummary:
            return "Receive monthly updates containing a summary of the past month's dining dollar and swipe use."
        case .universityEventAnnouncement: return "Notifications about significant university events."
        case .pennMobileUpdateAnnouncement: return "Get notified about major updates to Penn Mobile."
        default: return nil
        }
    }
}
