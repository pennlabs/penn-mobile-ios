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

class LabsLoginController: PennLoginController, IndicatorEnabled, Requestable {
        
    override var urlStr: String {
        return "https://platform.pennlabs.org/accounts/authorize/?response_type=code&client_id=CJmaheeaQ5bJhRL0xxlxK3b8VEbLb3dMfUAvI2TN&redirect_uri=https%3A%2F%2Fpennmobile.pennlabs.org%2Fcallback%2F&scope=read+introspection&state="
    }
    
    override var shouldLoadCookies: Bool {
        return false
    }
    
    private var code: String?
    
    private var shouldFetchAllInfo: Bool!
    private var completion: ((_ success: Bool) -> Void)!
    
    convenience init(fetchAllInfo: Bool = true, completion: @escaping (_ success: Bool) -> Void) {
        self.init()
        self.completion = completion
        self.shouldFetchAllInfo = fetchAllInfo
    }
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func handleSuccessfulNavigation(_ webView: WKWebView, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let code = code else {
            // Something went wrong, code not fetched
            decisionHandler(.cancel)
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        decisionHandler(.cancel)
        self.showActivity()
        OAuth2NetworkManager.instance.initiateAuthentication(code: code) { (accessToken) in
            if let accessToken = accessToken {
                OAuth2NetworkManager.instance.retrieveAccount(accessToken: accessToken) { (user) in
                    if let user = user, self.shouldFetchAllInfo {
                        PennInTouchNetworkManager.instance.getDegrees { (degrees) in
                            let student = Student(first: user.firstName, last: user.lastName, pennkey: user.username, email: user.email, pennid: user.pennid)
                            if user.email?.contains("wharton") ?? false || degrees?.hasDegreeInWharton() ?? false {
                                UserDefaults.standard.set(isInWharton: true)
                                GSRNetworkManager.instance.getSessionID { success in
                                    self.saveStudent(student) {
                                        self.dismiss(successful: true)
                                    }
                                }
                            } else {
                                self.saveStudent(student) {
                                    self.dismiss(successful: true)
                                }
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
            UserDefaults.standard.storeCookies()
            self.hideActivity()
            super.dismiss(animated: false, completion: nil)
            self.completion(successful)
        }
    }
    
    override func isSuccessfulRedirect(url: String, hasReferer: Bool) -> Bool {
        let targetUrl = "https://pennmobile.pennlabs.org/callback/?code="
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
    fileprivate func saveStudent(_ student: Student, _ callback: @escaping () -> Void) {
        UserDefaults.standard.saveStudent(student)
        UserDBManager.shared.saveStudent(student) { (accountID) in
            if let accountID = accountID {
                UserDefaults.standard.set(accountID: accountID)
            }
            callback()
            
            if accountID == nil {
                FirebaseAnalyticsManager.shared.trackEvent(action: "Attempt Login", result: "Failed Login", content: "Failed Login")
            } else {
                FirebaseAnalyticsManager.shared.trackEvent(action: "Attempt Login", result: "Successful Login", content: "Successful Login")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.getDiningBalance()
                    self.getDiningTransactions()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.getCourses()
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
            }
            UserDefaults.standard.storeCookies()
        }
    }
    
    fileprivate func getDiningBalance() {
        if let student = Student.getStudent(), student.isFreshman() {
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
