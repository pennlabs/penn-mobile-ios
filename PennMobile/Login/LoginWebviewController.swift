//
//  LoginWebviewController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import WebKit

class LoginWebviewController: PennLoginController {
    
    var loginCompletion: ((_ successful: Bool) -> Void)!
    
    private var coursesToSave: Set<Course>?
    
    override var urlStr: String {
        return "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do"
    }
    
    override func handleSuccessfulNavigation(_ webView: WKWebView, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        StudentNetworkManager.instance.getStudent(initialCallback: { student in
            DispatchQueue.main.async {
                decisionHandler(.cancel)
                UserDefaults.standard.storeCookies()
                if let student = student {
                    student.pennkey = self.pennkey
                    student.setEmail()
                    
                    if student.isInWharton(), GSRUser.getSessionID() == nil {
                        GSRNetworkManager.instance.getSessionID { success in
                            self.saveStudent(student)
                        }
                        return
                    } else {
                        self.saveStudent(student)
                    }
                } else {
                    self.dismiss(animated: true, completion: nil)
                    self.loginCompletion(false)
                }
            }
        }, allCoursesCallback: { courses in
            if let courses = courses {
                if let accountID = UserDefaults.standard.getAccountID() {
                    // Save courses to DB
                    UserDBManager.shared.saveCourses(courses, accountID: accountID)
                } else {
                    // If account ID has not yet been retrieved, cache courses and send them later
                    self.coursesToSave = courses
                }
            }
            UserDefaults.standard.storeCookies()
        })
    }
    
    fileprivate func saveStudent(_ student: Student) {
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
                self.dismiss(animated: true, completion: nil)
                self.loginCompletion(accountID != nil)
            }
        }
    }
}
