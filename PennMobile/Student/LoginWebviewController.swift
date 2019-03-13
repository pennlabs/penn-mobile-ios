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
    
    var loginCompletion: ((_ student: Student?) -> Void)!
    var coursesRetrieved: ((_ course: Set<Course>?) -> Void)!
    
    override var urlStr: String {
        return "https://pennintouch.apps.upenn.edu/pennInTouch/jsp/fast2.do"
    }
    
    override func handleSuccessfulNavigation(_ webView: WKWebView, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //let request = navigationAction.request
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { (cookies) in
            StudentNetworkManager.instance.getStudent(cookies: cookies, initialCallback: { student in
                DispatchQueue.main.async {
                    if let student = student {
                        student.pennkey = self.pennkey
                        student.setEmail()
                        self.loginCompletion(student)
                        self.dismiss(animated: true, completion: nil)
                        decisionHandler(.cancel)
                    } else {
                        self.loginCompletion(nil)
                        self.dismiss(animated: true, completion: nil)
                        decisionHandler(.cancel)
                    }
                }
            }, allCoursesCallback: { courses in
                self.coursesRetrieved(courses)
            })
        }
    }
}
