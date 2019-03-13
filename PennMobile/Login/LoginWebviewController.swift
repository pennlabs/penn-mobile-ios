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
    
    var loginCompletion: ((_ student: Student?, _ accountID: String?) -> Void)!
    var coursesRetrieved: ((_ course: Set<Course>?) -> Void)!
    
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
                        self.presentGSRWebviewLoginController {
                            self.saveStudent(student)
                        }
                        return
                    } else {
                        self.saveStudent(student)
                    }
                } else {
                    self.dismiss(animated: true, completion: nil)
                    self.loginCompletion(nil, nil)
                }
            }
        }, allCoursesCallback: { courses in
            self.coursesRetrieved(courses)
            UserDefaults.standard.storeCookies()
        })
    }
    
    fileprivate func presentGSRWebviewLoginController(_ completion: @escaping () -> Void) {
        let glc = GSRWebviewLoginController()
        glc.completion = completion
        glc.shouldAnimate = false
        let nvc = UINavigationController(rootViewController: glc)
        present(nvc, animated: false, completion: nil)
    }
    
    fileprivate func saveStudent(_ student: Student) {
        UserDBManager.shared.saveStudent(student) { (accountID) in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.loginCompletion(student, accountID)
            }
        }
    }
}
