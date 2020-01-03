//
//  LabsLoginController.swift
//  PennMobile
//
//  Created by Josh Doman on 12/11/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import WebKit
import SwiftyJSON
import CryptoKit
import CommonCrypto

protocol SHA256Hashable {}

extension SHA256Hashable {
    func hash(string: String) -> String {
        let inputData = Data(string.utf8)
        if #available(iOS 13, *) {
            let hashed = SHA256.hash(data: inputData)
            let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
            return hashString
        } else {
            // CryptoKit not available until iOS 13
            // https://www.agnosticdev.com/content/how-use-commoncrypto-apis-swift-5
            var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
            _ = inputData.withUnsafeBytes {
               CC_SHA256($0.baseAddress, UInt32(inputData.count), &digest)
            }
    
            var sha256String = ""
            for byte in digest {
               sha256String += String(format:"%02x", UInt8(byte))
            }
            return sha256String
        }
    }
}

class LabsLoginController: PennLoginController, IndicatorEnabled, Requestable, SHA256Hashable {
        
    override var urlStr: String {
        return "https://platform.pennlabs.org/accounts/authorize/?response_type=code&client_id=CJmaheeaQ5bJhRL0xxlxK3b8VEbLb3dMfUAvI2TN&redirect_uri=https%3A%2F%2Fpennlabs.org%2Fpennmobile%2Fios%2Fcallback%2F&code_challenge_method=S256&code_challenge=\(codeChallenge)scope=read+introspection&state="
    }
    
    override var shouldLoadCookies: Bool {
        return false
    }
    
    private let codeVerifier = String.randomString(length: 64)
    
    private var codeChallenge: String {
        return hash(string: codeVerifier)
    }
    
    private var code: String?
    
    private var shouldRetrieveRefreshToken = true
    private var shouldFetchAllInfo: Bool!
    private var completion: ((_ success: Bool) -> Void)!
    
    convenience init(fetchAllInfo: Bool = true, shouldRetrieveRefreshToken: Bool = true, completion: @escaping (_ success: Bool) -> Void) {
        self.init()
        self.completion = completion
        self.shouldFetchAllInfo = fetchAllInfo
        self.shouldRetrieveRefreshToken = shouldRetrieveRefreshToken
    }
    
    convenience init(fetchAllInfo: Bool = true) {
        self.init()
        self.completion = ({ _ in })
        self.shouldFetchAllInfo = fetchAllInfo
    }
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func handleSuccessfulNavigation(_ webView: WKWebView, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard shouldRetrieveRefreshToken else {
            // Refresh token does not to be retrieved. Dismiss controller immediately.
            decisionHandler(.cancel)
            self.dismiss(successful: true)
            return
        }
        
        guard let code = code else {
            // Something went wrong, code not fetched
            decisionHandler(.cancel)
            self.dismiss(successful: false)
            return
        }
        
        decisionHandler(.cancel)
        self.showActivity()
        OAuth2NetworkManager.instance.initiateAuthentication(code: code, codeVerifier: codeVerifier) { (accessToken) in
            if let accessToken = accessToken {
                OAuth2NetworkManager.instance.retrieveAccount(accessToken: accessToken) { (user) in
                    if let user = user, self.shouldFetchAllInfo {
                        let account = Account(user: user)
                        if account.isStudent {
                            PennInTouchNetworkManager.instance.getDegrees { (degrees) in
                                account.degrees = degrees
                                if account.email?.contains("wharton") ?? false || degrees?.hasDegreeInWharton() ?? false {
                                    UserDefaults.standard.set(isInWharton: true)
                                    GSRNetworkManager.instance.getSessionID { success in
                                        self.saveAccount(account) {
                                            self.dismiss(successful: true)
                                        }
                                    }
                                } else {
                                    self.saveAccount(account) {
                                        self.dismiss(successful: true)
                                    }
                                }
                            }
                        } else {
                            self.saveAccount(account) {
                                self.dismiss(successful: true)
                            }
                        }
                    } else {
                        self.dismiss(successful: user != nil)
                    }
                }
            } else {
                self.dismiss(successful: false)
            }
        }
    }
    
    func dismiss(successful: Bool) {
        DispatchQueue.main.async {
            if successful {
                UserDefaults.standard.setLastLogin()
            }
            UserDefaults.standard.storeCookies()
            self.hideActivity()
            super.dismiss(animated: true, completion: nil)
            self.completion(successful)
        }
    }
    
    override func isSuccessfulRedirect(url: String, hasReferer: Bool) -> Bool {
        let targetUrl = "https://pennlabs.org/pennmobile/ios/callback/?code="
        if url.contains(targetUrl) {
            if let code = url.split(separator: "=").last {
                self.code = String(code)
            }
            return true
        }
        return false
    }
}

// MARK: - Save Student {
extension LabsLoginController {
    fileprivate func saveAccount(_ account: Account, _ callback: @escaping () -> Void) {
        Account.saveAccount(account)
        UserDBManager.shared.saveAccount(account) { (accountID) in
            if let accountID = accountID {
                UserDefaults.standard.set(accountID: accountID)
            }
            callback()
            
            if accountID == nil {
                FirebaseAnalyticsManager.shared.trackEvent(action: "Attempt Login", result: "Failed Login", content: "Failed Login")
            } else {
                FirebaseAnalyticsManager.shared.trackEvent(action: "Attempt Login", result: "Successful Login", content: "Successful Login")
                
                if account.isStudent {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.getAndSaveNotificationAndPrivacyPreferences {
                            if UserDefaults.standard.getPreference(for: .collegeHouse) {
                                CampusExpressNetworkManager.instance.updateHousingData()
                            }
                        }
                        self.getDiningBalance()
                        self.getDiningTransactions()
                        self.getAndSaveLaundryPreferences()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.getCourses()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Retrieve Other Account Information
extension LabsLoginController {
    fileprivate func getCourses() {
        PennInTouchNetworkManager.instance.getCourses(currentTermOnly: false) { (courses) in
            if let courses = courses, let accountID = UserDefaults.standard.getAccountID() {
                // Save courses to DB if permission was granted
                UserDBManager.shared.saveCourses(courses, accountID: accountID)
                UserDefaults.standard.saveCourses(courses)
            }
            UserDefaults.standard.storeCookies()
        }
    }
    
    fileprivate func getDiningBalance() {
        if let student = Account.getAccount(), student.isFreshman() {
            UserDefaults.standard.set(hasDiningPlan: true)
        }
        
        CampusExpressNetworkManager.instance.getDiningBalanceHTML { (html, error) in
            guard let html = html else { return }
            UserDBManager.shared.parseAndSaveDiningBalanceHTML(html: html) { (hasPlan, balance) in
                if let hasDiningPlan = hasPlan {
                    UserDefaults.standard.set(hasDiningPlan: hasDiningPlan)
                }
            }
        }
    }
    
    fileprivate func getDiningTransactions() {
        PennCashNetworkManager.instance.getTransactionHistory { data in
            if let data = data, let str = String(bytes: data, encoding: .utf8) {
                UserDBManager.shared.saveTransactionData(csvStr: str)
                UserDefaults.standard.setLastTransactionRequest()
            }
        }
    }
    
    fileprivate func getAndSaveLaundryPreferences() {
        UserDBManager.shared.getLaundryPreferences { rooms in
            if let rooms = rooms {
                UserDefaults.standard.setLaundryPreferences(to: rooms)
            }
        }
    }
    
    fileprivate func getAndSaveNotificationAndPrivacyPreferences(_ completion: @escaping () -> Void) {
        UserDBManager.shared.syncUserSettings { (success) in
            completion()
        }
    }
    
    fileprivate func obtainCoursePermission(_ callback: @escaping (_ granted: Bool) -> Void) {
        self.hideActivity()
        let title = "\"Penn Mobile\" Would Like To Access Your Courses"
        let message = "Access is needed to display your course schedule on the app."
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Don't Allow", style: .default, handler:{ (UIAlertAction) in
            callback(false)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (UIAlertAction) in
            callback(true)
        }))
        present(alert, animated: true)
    }
}

extension Set where Element == Degree {
    func hasDegreeInWharton() -> Bool {
        return self.contains { (degree) -> Bool in
            return degree.schoolCode == "WH"
        }
    }
}
