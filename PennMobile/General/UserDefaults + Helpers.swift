//
//  UserDefaults + Helpers.swift
//  PennMobile
//
//  Created by Josh Doman on 7/31/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation
import WebKit

//MARK: UserDefaultsKeys
extension UserDefaults {
    enum UserDefaultsKeys: String, CaseIterable {
        case account
        case accountID
        case deviceUUID
        case controllerSettings
        case sessionCount
        case laundryPreferences
        case isOnboarded
        case gsrUSer
        case appVersion
        case cookies
        case wharton
        case coursePermission
        case hasDiningPlan
        case lastLogin
        case unsentLogs
        case lastTransactionRequest
        case authedIntoShibboleth
        case courses
        case housing
        case privacyPreferences
        case notificationPreferences
    }
    
    func clearAll() {
        for key in UserDefaultsKeys.allCases {
            removeObject(forKey: key.rawValue)
        }
    }
}

// MARK: AccountID
extension UserDefaults {
    func set(accountID: String) {
        set(accountID, forKey: UserDefaultsKeys.accountID.rawValue)
        synchronize()
    }

    func getAccountID() -> String? {
        return string(forKey: UserDefaultsKeys.accountID.rawValue)
    }

    func clearAccountID() {
        removeObject(forKey: UserDefaultsKeys.accountID.rawValue)
    }
}

// MARK: Permanent DeviceUUID
extension UserDefaults {
    func set(deviceUUID: String) {
        set(deviceUUID, forKey: UserDefaultsKeys.deviceUUID.rawValue)
        synchronize()
    }

    func getDeviceUUID() -> String? {
        return string(forKey: UserDefaultsKeys.deviceUUID.rawValue)

    }

    func isFirstTimeUser() -> Bool {
        return getDeviceUUID() == nil
    }
}

// MARK: VC Controller Settings (order of VCs)
extension UserDefaults {
    func set(vcDisplayNames: [String]) {
        set(vcDisplayNames, forKey: UserDefaultsKeys.controllerSettings.rawValue)
        synchronize()
    }

    func getVCDisplayNames() -> [String]? {
        return array(forKey: UserDefaultsKeys.controllerSettings.rawValue) as? [String]
    }
}

extension UserDefaults {
    func set(sessionCount: Int) {
        set(sessionCount, forKey: UserDefaultsKeys.sessionCount.rawValue)
        synchronize()
    }

    func getSessionCount() -> Int? {
        return integer(forKey: UserDefaultsKeys.sessionCount.rawValue)
    }

    func incrementSessionCount() {
        if let count = getSessionCount() {
            UserDefaults.standard.set(sessionCount: count + 1)
        } else {
            set(sessionCount: 0)
        }
    }
}

// MARK: Laundry Preferences
extension UserDefaults {
    func setLaundryPreferences(to ids: [Int]) {
        set(ids, forKey: UserDefaultsKeys.laundryPreferences.rawValue)
        synchronize()
    }

    func getLaundryPreferences() -> [Int]? {
        return array(forKey: UserDefaultsKeys.laundryPreferences.rawValue) as? [Int]
    }
}

// MARK: Onboarding Status
extension UserDefaults {
    func setIsOnboarded(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isOnboarded.rawValue)
        synchronize()
    }

    func isOnboarded() -> Bool {
        return bool(forKey: UserDefaultsKeys.isOnboarded.rawValue)
    }
}

// MARK: GSR User
extension UserDefaults {
    func setGSRUser(value: GSRUser) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.gsrUSer.rawValue)
        }
        synchronize()
    }

    func getGSRUser() -> GSRUser? {
        let decoder = JSONDecoder()
        if let decodedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.gsrUSer.rawValue) {
            return try? decoder.decode(GSRUser.self, from: decodedData)
        }
        return nil
    }

    func clearGSRUser() {
        removeObject(forKey: UserDefaultsKeys.gsrUSer.rawValue)
    }
}

// MARK: Account
extension UserDefaults {
    func saveAccount(_ account: Account) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(account) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.account.rawValue)
        }
        synchronize()
    }

    func getAccount() -> Account? {
        let decoder = JSONDecoder()
        if let decodedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.account.rawValue) {
            return try? decoder.decode(Account.self, from: decodedData)
        }
        return nil
    }

    func clearAccount() {
        removeObject(forKey: UserDefaultsKeys.account.rawValue)
    }
}

// MARK: - Courses
extension UserDefaults {
    func saveCourses(_ courses: Set<Course>) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(courses) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.courses.rawValue)
        }
        synchronize()
    }

    func getCourses() -> Set<Course>? {
        let decoder = JSONDecoder()
        if let decodedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.courses.rawValue) {
            return try? decoder.decode(Set<Course>.self, from: decodedData)
        }
        return nil
    }

    func clearCourses() {
        removeObject(forKey: UserDefaultsKeys.courses.rawValue)
    }
}

// MARK: - App Version
extension UserDefaults {
    func isNewAppVersion() -> Bool {
        let prevAppVersion = string(forKey: UserDefaultsKeys.appVersion.rawValue) ?? ""
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        return prevAppVersion != version
    }

    func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        return version
    }

    func setAppVersion() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        set(version, forKey: UserDefaultsKeys.appVersion.rawValue)
        synchronize()
    }
}

// MARK: - Wharton Flag
extension UserDefaults {
    func set(isInWharton: Bool) {
        set(isInWharton, forKey: UserDefaultsKeys.wharton.rawValue)
        synchronize()
    }

    func isInWharton() -> Bool {
        return bool(forKey: UserDefaultsKeys.wharton.rawValue)
    }

    func clearWhartonFlag() {
        removeObject(forKey: UserDefaultsKeys.wharton.rawValue)
    }
}

// MARK: - Has Dining Plan
extension UserDefaults {
    func set(hasDiningPlan: Bool) {
        set(hasDiningPlan, forKey: UserDefaultsKeys.hasDiningPlan.rawValue)
        synchronize()
    }

    func hasDiningPlan() -> Bool {
        return bool(forKey: UserDefaultsKeys.hasDiningPlan.rawValue)
    }

    func clearHasDiningPlan() {
        removeObject(forKey: UserDefaultsKeys.hasDiningPlan.rawValue)
    }
}

// MARK: - Cookies
extension UserDefaults {
    func storeCookies() {
        guard let cookies = HTTPCookieStorage.shared.cookies else { return }

        var cookieDict = [String : AnyObject]()
        for cookie in cookies {
            cookieDict[cookie.name + cookie.domain] = cookie.properties as AnyObject?
        }

        set(cookieDict, forKey: UserDefaultsKeys.cookies.rawValue)
    }

    func restoreCookies() {
        let cookiesStorage = HTTPCookieStorage.shared
        if let cookieDictionary = self.dictionary(forKey: UserDefaultsKeys.cookies.rawValue) {
            for (_, cookieProperties) in cookieDictionary {
                if let cookie = HTTPCookie(properties: cookieProperties as! [HTTPCookiePropertyKey : Any] ) {
                    cookiesStorage.setCookie(cookie)
                }
            }
        }
    }

    func clearCookies() {
        removeObject(forKey: UserDefaultsKeys.cookies.rawValue)
    }
}

// MARK: - Course Permission
extension UserDefaults {
    func setCoursePermission(_ granted: Bool) {
        set(granted, forKey: UserDefaultsKeys.coursePermission.rawValue)
        synchronize()
    }

    func coursePermissionGranted() -> Bool {
        return bool(forKey: UserDefaultsKeys.coursePermission.rawValue)
    }
}

// MARK: - Last Login
extension UserDefaults {
    func setLastLogin() {
        set(Date(), forKey: UserDefaultsKeys.lastLogin.rawValue)
        synchronize()
    }

    func getLastLogin() -> Date? {
        return object(forKey: UserDefaultsKeys.lastLogin.rawValue) as? Date
    }
}

// MARK: - Unsent Event Logs
extension UserDefaults {
    func saveEventLogs(events: Set<FeedAnalyticsEvent>) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(events) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.unsentLogs.rawValue)
        }
        synchronize()
    }

    func getUnsentEventLogs() -> Set<FeedAnalyticsEvent>? {
        let decoder = JSONDecoder()
        if let decodedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.unsentLogs.rawValue) {
            return try? decoder.decode( Set<FeedAnalyticsEvent>.self, from: decodedData)
        }
        return nil
    }

    func clearEventLogs() {
        removeObject(forKey: UserDefaultsKeys.unsentLogs.rawValue)
    }
}

// MARK: - Last Transaction Request
extension UserDefaults {
    func setLastTransactionRequest() {
        set(Date(), forKey: UserDefaultsKeys.lastTransactionRequest.rawValue)
        synchronize()
    }

    func getLastTransactionRequest() -> Date? {
        return object(forKey: UserDefaultsKeys.lastTransactionRequest.rawValue) as? Date
    }

    func clearLastTransactionRequest() {
        removeObject(forKey: UserDefaultsKeys.lastTransactionRequest.rawValue)
    }
}

// MARK: - Authed Into Shibboleth
extension UserDefaults {
    func setShibbolethAuth(authedIn: Bool) {
        set(authedIn, forKey: UserDefaultsKeys.authedIntoShibboleth.rawValue)
        synchronize()
    }
    
    func isAuthedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.authedIntoShibboleth.rawValue)
    }
}

// MARK: - Housing
extension UserDefaults {
    func saveHousingResult(_ result: HousingResult) {
        let currentResults = getHousingResults() ?? Array<HousingResult>()
        var newResults = currentResults.filter { $0.start != result.start }
        newResults.append(result)
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(newResults) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.housing.rawValue)
        }
        synchronize()
    }
    
    func getHousingResults() -> Array<HousingResult>? {
        let decoder = JSONDecoder()
        if let decodedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.housing.rawValue) {
            return try? decoder.decode(Array<HousingResult>.self, from: decodedData)
        }
        return nil
    }
    
    func isOnCampus() -> Bool? {
        guard let results = getHousingResults() else {
            return nil
        }
        let now = Date()
        let start = now.month <= 5 ? now.year - 1 : now.year
        let filteredResults = results.filter { $0.start == start }
        if filteredResults.isEmpty {
            return nil
        } else {
            return filteredResults.contains { !$0.offCampus }
        }
    }
}

// MARK: - Privacy Settings
extension UserDefaults {
    func savePrivacyPreferences(to preferences: Set<PrivacyPreference>) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.privacyPreferences.rawValue)
        }
    }

    func getPrivacyPreferences() -> Set<PrivacyPreference>? {
        let decoder = JSONDecoder()
        if let decodedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.privacyPreferences.rawValue) {
            return try? decoder.decode(Set<PrivacyPreference>.self, from: decodedData)
        }
        return nil
    }

    func clearPrivacyPreferences() {
        removeObject(forKey: UserDefaultsKeys.privacyPreferences.rawValue)
    }
}

// MARK: - Notification Settings
extension UserDefaults {
    func saveNotificationPreferences(to preferences: Set<NotificationPreference>) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.notificationPreferences.rawValue)
        }
    }

    func getNotificationPreferences() -> Set<NotificationPreference>? {
        let decoder = JSONDecoder()
        if let decodedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.notificationPreferences.rawValue) {
            return try? decoder.decode(Set<NotificationPreference>.self, from: decodedData)
        }
        return nil
    }

    func clearNotificationPreferences() {
        removeObject(forKey: UserDefaultsKeys.notificationPreferences.rawValue)
    }
}
