//
//  LoginWebviewController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import WebKit
import WKZombie

class LoginWebviewController: PennLoginController, IndicatorEnabled {
    
    var loginCompletion: ((_ successful: Bool) -> Void)?
    
    private var coursesToSave: Set<Course>?
    private var coursesPermission: Bool?
    
    override var urlStr: String {
        return "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do"
    }
    
    override func handleSuccessfulNavigation(_ webView: WKWebView, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.showActivity()
        PennInTouchNetworkManager.instance.getStudent { (student) in
            DispatchQueue.main.async {
                decisionHandler(.cancel)
                if let student = student {
                    UserDefaults.standard.storeCookies()
                    student.pennkey = self.pennkey
                    student.setEmail()
                    
                    if student.isInWharton(), GSRUser.getSessionID() == nil {
                        GSRNetworkManager.instance.getSessionID { success in
                            self.saveStudent(student)
                        }
                    } else {
                        self.saveStudent(student)
                    }
                } else {
                    FirebaseAnalyticsManager.shared.trackEvent(action: "Attempt Login", result: "Failed Login", content: "Failed Login")
                    self.hideActivity()
                    UserDefaults.standard.clearCookies()
                    HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
                    self.dismiss(animated: true, completion: nil)
                    self.loginCompletion?(false)
                }
                UserDefaults.standard.storeCookies()
                
                // Create TOTP App
//                TOTPFetcher.instance.fetchAndSaveTOTPSecret()
            }
        }
    }
    
    private func getRemainingCourses() {
        // Check if student not null and course permission has been granted
        guard let student = Student.getStudent(), UserDefaults.standard.coursePermissionGranted() else { return }
        // Wait 1 second for homepage to be fetched from server
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            PennInTouchNetworkManager.instance.getCourses(currentTermOnly: false) { (courses) in
                if let courses = courses,
                    let accountID = UserDefaults.standard.getAccountID() {
                    // Save courses to DB if permission was granted
                    UserDBManager.shared.saveCourses(courses, accountID: accountID)
                    student.courses = courses
                }
                UserDefaults.standard.storeCookies()
            }
        }
    }
    
    private func getDiningBalance() {
        if let student = Student.getStudent(), student.isFreshman() {
            DiningViewModel.ShowDiningPlan = true
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
    
    private func getDiningTransactions(after wait: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
            PennCashNetworkManager.instance.getTransactionHistory { data in
                if let data = data, let str = String(bytes: data, encoding: .utf8) {
                    UserDBManager.shared.saveTransactionData(csvStr: str)
                    UserDefaults.standard.setLastTransactionRequest()
                }
            }
        }
    }
    
    fileprivate func saveStudent(_ student: Student) {
        if let courses = student.courses, !courses.isEmpty, !UserDefaults.standard.coursePermissionGranted() {
            DispatchQueue.main.async {
                self.obtainCoursePermission { (granted) in
                    UserDefaults.standard.setCoursePermission(granted)
                    if !granted {
                        student.courses = nil
                    }
                    self.saveStudentHelper(student)
                }
            }
        } else {
            saveStudentHelper(student)
        }
    }
    
    fileprivate func saveStudentHelper(_ student: Student) {
        UserDefaults.standard.saveStudent(student)
        UserDefaults.standard.set(isInWharton: student.isInWharton())
        UserDBManager.shared.saveStudent(student) { (accountID) in
            DispatchQueue.main.async {
                if let accountID = accountID {
                    UserDefaults.standard.set(accountID: accountID)
                    if let coursesToSave = self.coursesToSave, !coursesToSave.isEmpty {
                        // Send cached courses to server
                        UserDBManager.shared.saveCourses(coursesToSave, accountID: accountID)
                    }
                }
                self.hideActivity()
                self.dismiss(animated: true, completion: nil)
                self.loginCompletion?(accountID != nil)
                self.getRemainingCourses()
                self.getDiningBalance()
                self.getDiningTransactions(after: 0.5)
                TOTPFetcher.instance.fetchAndSaveTOTPSecret()
                
                if accountID == nil {
                    FirebaseAnalyticsManager.shared.trackEvent(action: "Attempt Login", result: "Failed Login", content: "Failed Login")
                } else {
                    FirebaseAnalyticsManager.shared.trackEvent(action: "Attempt Login", result: "Successful Login", content: "Successful Login")
                }
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
