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

enum PrivacyOption: String, CaseIterable {
    case anonymizedCourseSchedule
    case diningBalanceAndHistory
    case collegeHouse
    case academicIdentity
    
    // Options to be actually shown to the user
    static let visibleOptions: [PrivacyOption] = [
        .anonymizedCourseSchedule, .collegeHouse, .academicIdentity
    ]
    
    // Options that required the use of anonymized data
    static let anonymizedOptions: [PrivacyOption] = [
        .anonymizedCourseSchedule
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
            return "Dining balance data is used to provide you with your dining dollar and swipe balance. We track changes over time, which we use to provide monthly summaries and to predict how many you swipes you will have left over.\n\nNOTE: Disabling this setting will disable all dining balance features."
        case .collegeHouse: return "College house information is used to recommend laundry rooms and dining halls. College houses may also post announcements and upcoming events on Penn Mobile."
        case .academicIdentity: return "Your school and graduation year is used to present you with more relevant events on the homepage. For example, the 2022 Class Board may wish to alert all '22 users about an upcoming giveaway."
        }
    }
    
    var defaultValue: Bool {
        switch self {
        case .diningBalanceAndHistory: return UserDefaults.standard.hasDiningPlan()
        case .academicIdentity: return Account.getAccount()?.isStudent ?? false
        case .collegeHouse: return Account.getAccount()?.isStudent ?? false
        default: return false
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .anonymizedCourseSchedule: return true
        case .academicIdentity: return true
        case .collegeHouse: return true
        default: return false
        }
    }
    
    // MARK: User Defaults Keys
    // These keys ARE cleared when UserDefaults is wiped.
    
    // A key used by UserDefaults to tell if and when we've asked for this privacy option
    var didRequestKey: String {
        return "didRequest_" + self.rawValue
    }
    
    // A key used by UserDefaults to tell if and when we've shared data for this option
    var didShareKey: String {
        return "didShare_" + self.rawValue
    }
    
    
    // This key is NOT cleared when UserDefaults is wiped.
    // A key used by UserDefaults to store a UUID which points to this user's anonymous data on the server for this option. This should never leave the device
    var privateIDKey: String? {
        // TODO: Use keychain + hashing penn password and pennid to get id.
        guard let accountId = UserDefaults.standard.getAccountID() else { return nil }
        return "privateID_" + self.rawValue + "_" + accountId
    }
    
    var privateUUID: String? {
        UserDefaults.standard.getPrivacyUUID(for: self)
    }
}

extension PrivacyOption {
    func givePermission(_ completion: @escaping (_ success: Bool) -> Void) {
        UserDefaults.standard.set(self, to: true)
        UserDBManager.shared.saveUserPrivacySettings { (successSave) in
            if !successSave {
                // Unable to save permissions. Reverse change in UserDefaults.
                UserDefaults.standard.set(self, to: false)
                completion(false)
                return
            }
            
            switch self {
            case .anonymizedCourseSchedule:
                PennInTouchNetworkManager.instance.getCourses { (result) in
                    if let courses = try? result.get() {
                        UserDefaults.standard.setLastShareDate(for: self)
                        UserDBManager.shared.saveCoursesAnonymously(courses)
                    }
                }
            case .collegeHouse:
                // Save the current semester and then save previous semesters stored in UserDefaults
                CampusExpressNetworkManager.instance.updateHousingData { (success) in
                    UserDBManager.shared.saveMultiyearHousingData()
                }
            case .academicIdentity:
                PennInTouchNetworkManager.instance.getDegrees { (degrees) in
                    if let degrees = degrees {
                        UserDBManager.shared.saveAcademicInfo(degrees)
                        UserDefaults.standard.set(isInWharton: degrees.hasDegreeInWharton())
                    }
                }
            default: break
            }
            
            // Privacy setting successfully saved even if data not able to be fetched, so return success
            completion(true)
        }
    }
    
    func removePermission(_ completion: @escaping (_ success: Bool) -> Void) {
        UserDefaults.standard.set(self, to: false)
        UserDBManager.shared.saveUserPrivacySettings { (successSave) in
            if !successSave {
                // Unable to save permissions. Reverse change in UserDefaults.
                UserDefaults.standard.set(self, to: true)
                completion(false)
                return
            }
            
            switch self {
            case .anonymizedCourseSchedule:
                UserDefaults.standard.removeObject(forKey: self.didShareKey)
                UserDBManager.shared.deleteAnonymousCourses(completion)
            case .collegeHouse:
                UserDBManager.shared.deleteHousingData(completion)
            case .academicIdentity:
                UserDBManager.shared.deleteAcademicInfo(completion)
            default: completion(true)
            }
        }
    }
}
