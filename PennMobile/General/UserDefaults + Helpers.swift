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
        for option in PrivacyOption.allCases {
            removeObject(forKey: option.didRequestKey)
            removeObject(forKey: option.didShareKey)
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
    
    // MARK: Get and Save Preferences
    // Set values for each privacy option
    func set(_ privacyOption: PrivacyOption, to newValue: Bool) {
        var prefs = getAllPrivacyPreferences()
        prefs[privacyOption.rawValue] = newValue
        saveAll(privacyPreferences: prefs)
    }
    
    // Get values for each privacy option (default to false if no preference exists)
    func getPreference(for option: PrivacyOption) -> Bool {
        let prefs = getAllPrivacyPreferences()
        return prefs[option.rawValue] ?? option.defaultValue
    }
    
    // Fetch preferences from disk
    func getAllPrivacyPreferences() -> PrivacyPreferences {
        let decoder = JSONDecoder()
        if let decodedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.privacyPreferences.rawValue) {
            return (try? decoder.decode(PrivacyPreferences.self, from: decodedData)) ?? .init()
        }
        return .init()
    }
    
    // Save all privacy preferences to disk
    func saveAll(privacyPreferences: PrivacyPreferences) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(privacyPreferences) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.privacyPreferences.rawValue)
        }
    }

    private func clearPrivacyPreferences() {
        removeObject(forKey: UserDefaultsKeys.privacyPreferences.rawValue)
    }
    
    // MARK: Last Permission Request Date
    // Set values representing whether or not permission was requested for a given privacy option
    // This is not synced to the server, so we ask a user again if they ever delete the app or get a new phone
    func setLastDidAskPermission(for privacyOption: PrivacyOption) {
        UserDefaults.standard.set(Date(), forKey: privacyOption.didRequestKey)
    }
    
    // Get the last date we asked for this option, or nil if we've never asked (on this installation)
    func getLastDidAskPermission(for privacyOption: PrivacyOption) -> Date? {
        UserDefaults.standard.value(forKey: privacyOption.didRequestKey) as? Date
    }
    
    // MARK: Last Data Sharing Date
    // Set the last date we shared data corresponding to this option (ex: when did we last upload courses)
    func setLastShareDate(for privacyOption: PrivacyOption) {
        UserDefaults.standard.set(Date(), forKey: privacyOption.didShareKey)
    }
    // Get the last date we shared data for this option
    func getLastShareDate(for privacyOption: PrivacyOption) -> Date? {
        UserDefaults.standard.value(forKey: privacyOption.didShareKey) as? Date
    }
    
    // MARK: Privacy Option UUID
    // Each privacy option has its own UUID, which is sent to the server along with any anonymous data to allow us to track that data over time, as well as delete it if requested by the user.
    func getPrivacyUUID(for privacyOption: PrivacyOption) -> String? {
        if let privateKey = privacyOption.privateIDKey {
            if let uuid = UserDefaults.standard.string(forKey: privateKey) {
                return uuid
            } else {
                let uuid = String.randomString(length: 32)
                UserDefaults.standard.set(uuid, forKey: privateKey)
                return uuid
            }
        }
        return nil
    }
}

// MARK: - Notification Settings
extension UserDefaults {
    // Set values for each notification option
    func set(_ notificationOption: NotificationOption, to newValue: Bool) {
        var prefs = getAllNotificationPreferences()
        prefs[notificationOption.rawValue] = newValue
        saveAll(notificationPreferences: prefs)
    }
    
    // Get values for each notification option (default to true if no preference exists)
    func getPreference(for option: NotificationOption) -> Bool {
        let prefs = getAllNotificationPreferences()
        return prefs[option.rawValue] ?? option.defaultValue
    }
    
    // Fetch preferences from disk
    func getAllNotificationPreferences() -> NotificationPreferences {
        let decoder = JSONDecoder()
        if let decodedData = UserDefaults.standard.data(forKey: UserDefaultsKeys.notificationPreferences.rawValue) {
            return (try? decoder.decode(NotificationPreferences.self, from: decodedData)) ?? .init()
        }
        return .init()
    }
    
    // Save all notification preferences to disk
    func saveAll(notificationPreferences: NotificationPreferences) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(notificationPreferences) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.notificationPreferences.rawValue)
        }
    }

    private func clearNotificationPreferences() {
        removeObject(forKey: UserDefaultsKeys.notificationPreferences.rawValue)
    }
}
// MARK: - Two Factor Enabled flag
extension UserDefaults {
    func setTwoFactorEnabled(to newValue: Bool) {
        UserDefaults.standard.set(newValue, forKey: "TOTPEnabled")
        setTwoFactorEnabledDate(Date())
    }
    
    func getTwoFactorEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "TOTPEnabled")
    }
    
    func getTwoFactorEnabledDate() -> Date? {
        return UserDefaults.standard.value(forKey: "TOTPEnabledDate") as? Date
    }
    
    fileprivate func setTwoFactorEnabledDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: "TOTPEnabledDate")
    }
}
