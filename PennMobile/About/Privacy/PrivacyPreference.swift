//
//  PrivacyPreference.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

typealias PrivacyPreferences = Dictionary<String, Bool>

// Outside API -- UserDefaults.setPrivacyOption(.courses, to: false)
// Internally -- just a Dictionary of String : Bool
// where the strings are dictated by those enum cases
// that way when they get decoded, they are always valid and we don't erase old options
// when setPrivacyOption is called, we just override the value at key = Enum.rawvalue

// When decoding, we just decode a dictionary of strings to enums
// We also have an API for querying the privacy info

enum PrivacyOption: String {
    case anonymizedCourseEnrollment
    case anonymizedDiningTransactions
    case collegeHouse
    case academicIdentity
    
    // Options to be actually shown to the user
    static let visibleOptions: [PrivacyOption] = [
        .anonymizedCourseEnrollment, .anonymizedDiningTransactions, .collegeHouse, .academicIdentity
    ]
    
    var cellTitle: String {
        switch self {
        case .anonymizedCourseEnrollment: return "Share anonymized course enrollments"
        case .anonymizedDiningTransactions: return "Share anonymized dining transactions"
        case .collegeHouse: return "Share college house"
        case .academicIdentity: return "Share academic identity"
        default: return ""
        }
    }
    
    var cellFooterDescription: String {
        switch self {
        case .anonymizedCourseEnrollment: return "Course data is used by other Penn Labs products to provide course recommendations. Your data is anonymized before entering our dataset."
        case .anonymizedDiningTransactions:
            return "Dining transaction data is used to provide you with your dining dollars and swipes balances. We also use it to power our prediction algorithms, for example to predict how many days of dining dollars you have remaining. Disabling this setting will disable all dining transaction features."
        case .collegeHouse: return "College house information is used to recommend laundry rooms and dining halls. College houses may also post announcements or target events through Penn Mobile."
        case .academicIdentity: return "Your schools, graduation year, majors, and minors are used to present you with more relevant events. For example, the 2022 Class Board may wish to alert only '22 users about an event."
        default: return ""
        }
    }
}
