//
//  NotificationPreference.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct NotificationPreference: Codable, Hashable {
    // Default to permission not being given
    var decision: Bool = false
    let option: NotificationOption
    
    // Options to be actually shown to the user
    static let visibleOptions: [NotificationOption] = [
        .upcomingStudyRoomReminder, .laundryMachineCycleComplete, .universityEventAnnouncement
    ]
}

enum NotificationOption: String, Codable, CaseIterable {
    case pennMobileUpdateAnnouncement
    case upcomingStudyRoomReminder
    case laundryMachineCycleComplete
    case collegeHouseAnnouncement
    case universityEventAnnouncement
    case dailyMenuNotification
    case dailyMenuNotificationBreakfast
    case dailyMenuNotificationLunch
    case dailyMenuNotificationDinner
}
