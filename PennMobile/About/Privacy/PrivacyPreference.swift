//
//  PrivacyPreference.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

typealias PrivacyPreferences = Dictionary<String, Bool>

/*
 Privacy preferences are stored in UserDefaults as a String:Bool mapping, where
 String is the unique key of the privacy option (PrivacyOption.rawValue) and Bool
 is whether or not the option is enabled.
 
 TO SET PRIVACY OPTIONS: use the UserDefaults.standard.setPrivacyOption() method.
 
 After setting privacy options, you should attempt to send the changes to the server.
 Do this with UserDBManager.shared.saveUserPrivacySettings()
 
 TO FETCH PRIVACY OPTIONS: use UserDBManager.shared.syncUserSettings() to pull settings
 from the database. Then use UserDefaults.standard.getPreference(forOption) to get
 individual preferences values for each option.
*/

enum PrivacyOption: String {
    case anonymizedCourseSchedule
    case diningBalanceAndHistory
    case collegeHouse
    case academicIdentity
    
    // Options to be actually shown to the user
    static let visibleOptions: [PrivacyOption] = [
        .anonymizedCourseSchedule, .diningBalanceAndHistory, .collegeHouse, .academicIdentity
    ]
    
    var cellTitle: String {
        switch self {
        case .anonymizedCourseSchedule: return "Anonymized course schedule"
        case .diningBalanceAndHistory: return "Dining balance & transaction history"
        case .collegeHouse: return "College house"
        case .academicIdentity: return "Academic identity"
        }
    }
    
    var cellFooterDescription: String {
        switch self {
        case .anonymizedCourseSchedule: return "Other Penn Labs products aggregate past schedules to provide course recommendations to students. Your data is anonymized before entering our dataset."
        case .diningBalanceAndHistory:
            return "Dining balance data is used to provide you with your dining dollar and swipe balance. We track changes over time, which we use to provide monthly summaries and to predict how many you swipes you will have left over. Disabling this setting will disable all dining balance features."
        case .collegeHouse: return "College house information is used to recommend laundry rooms and dining halls. College houses may also post announcements and upcoming events on Penn Mobile."
        case .academicIdentity: return "Your school and graduation year is used to present you with more relevant events on the homepage. For example, the 2022 Class Board may wish to alert all '22 users about an upcoming giveaway."
        }
    }
}
