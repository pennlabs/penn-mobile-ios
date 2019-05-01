//
//  RootViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/25/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

// Source: https://medium.com/@stasost/ios-root-controller-navigation-3625eedbbff
class RootViewController: UIViewController {
    private var current: UIViewController
    
    private var lastLoginAttempt: Date?
    
    init() {
        self.current = SplashViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let now = Date()
        let components = Calendar.current.dateComponents([.year], from: now)
        let january = Calendar.current.date(from: components)!
        let june = january.add(months: 5)
        let august = january.add(months: 7)
        
        if UserDefaults.standard.isNewAppVersion() {
            UserDefaults.standard.setAppVersion()
            
            if UserDefaults.standard.getAccountID() != nil && now < august {
                // If user is logged in and is not yet August, set last login to now
                // NOTE: this code will be removed in next app update
                UserDefaults.standard.setLastLogin()
            }
        }
        
        if let lastLogin = UserDefaults.standard.getLastLogin() {
            if january <= now && now <= june {
                if lastLogin < january {
                    // Last logged in before current Spring Semester -> Require new log in
                    clearAccountData()
                }
            } else if now >= august {
                if lastLogin < august {
                    // Last logged in before current Fall Semester -> Require new log in
                    clearAccountData()
                }
            }
        } else {
            clearAccountData()
        }
        
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
        
        UserDefaults.standard.restoreCookies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.current is HomeNavigationController {
            if UserDefaults.standard.getAccountID() == nil {
                // Switch to logout screen if user is not logged in
                self.switchToLogout(false)
            } else {
                ControllerModel.shared.visibleVC().viewWillAppear(animated)
            }
        }
        
        // If student is in Wharton but does not have a session ID, retrieve one if possible
        if UserDefaults.standard.isInWharton() && GSRUser.getSessionID() == nil {
            let now = Date()
            if lastLoginAttempt != nil && lastLoginAttempt!.minutesFrom(date: now) < 720 {
                // Don't try to auto re-login if it's been less than 12 hours since last attempt
                return
            }
            self.lastLoginAttempt = now
            // Wait 0.5 seconds so that the home page request is not held up
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                GSRNetworkManager.instance.getSessionIDWithDownFlag { (success, serviceDown) in
                    DispatchQueue.main.async {
                        if !success && !serviceDown && self.current is HomeNavigationController {
                            // Only pop up login controller if not successful, service is not down, and not on login screen
                            let gwc = GSRWebviewLoginController()
                            let nvc = UINavigationController(rootViewController: gwc)
                            self.current.present(nvc, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func showLoginScreen() {
        let loginController = LoginController()
        moveto(controller: loginController)
    }
    
    func showMainScreen() {
        let tabBarController = TabBarController()
        let homeNVC = HomeNavigationController(rootViewController: tabBarController)
        moveto(controller: homeNVC)
    }
    
    func switchToMainScreen() {
        let tabBarController = TabBarController()
        let homeNVC = HomeNavigationController(rootViewController: tabBarController)
        animateFadeTransition(to: homeNVC)
        
        // Keep track locally of app sessions (for app review prompting)
        let sessionCount = UserDefaults.standard.integer(forKey: "launchCount")
        UserDefaults.standard.set(sessionCount+1, forKey:"launchCount")
        UserDefaults.standard.synchronize()
        
        // This code will ONLY present the review if we're not running Fastlane UI Automation (for screenshots)
        if !UIApplication.isRunningFastlaneTest {
            if sessionCount == 3 {
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    func switchToLogout(_ shouldClearData: Bool = true) {
        let loginController = LoginController()
        animateDismissTransition(to: loginController)
        
        if shouldClearData {
            clearAccountData()
        }
        
        // Clear cache so that home title updates with new first name
        guard let homeVC = ControllerModel.shared.viewController(for: .home) as? HomeViewController else {
            return
        }
        homeVC.clearCache()
    }
    
    fileprivate func clearAccountData() {
        HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
        UserDefaults.standard.clearAccountID()
        UserDefaults.standard.clearCookies()
        UserDefaults.standard.clearWhartonFlag()
        UserDefaults.standard.clearHasDiningPlan()
        Student.clear()
        GSRUser.clear()
    }
    
    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        current.willMove(toParent: nil)
        addChild(new)
        
        transition(from: current, to: new, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
        }) { completed in
            self.current.removeFromParent()
            new.didMove(toParent: self)
            self.current = new
            completion?()
        }
    }
    
    private func animateDismissTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        current.willMove(toParent: nil)
        addChild(new)
        transition(from: current, to: new, duration: 0.2, options: [.transitionCrossDissolve], animations: {
        }) { completed in
            self.current.removeFromParent()
            new.didMove(toParent: self)
            self.current = new
            completion?()
        }
    }
    
    private func moveto(controller: UIViewController) {
        addChild(controller)
        controller.view.frame = view.bounds
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = controller
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Updated database if needed
extension RootViewController {
    func updateDatabaseIfNeeded() {
        if let student = Student.getStudent() {
            if let accountID = UserDefaults.standard.getAccountID() {
                if let courses = student.courses {
                    // Check if any courses have no start, end date. If so, update DB, which can now handle this.
                    var hasEmptyDate = false
                    for course in courses {
                        if course.startDate == "" || course.endDate == "" {
                            hasEmptyDate = true
                            break
                        }
                    }
                    
                    if hasEmptyDate {
                        UserDBManager.shared.saveCourses(courses, accountID: accountID)
                    }
                } else {
                    // Pop up login controller to re-retrieve data
                    let lwc = LoginWebviewController()
                    let nvc = UINavigationController(rootViewController: lwc)
                    self.current.present(nvc, animated: true, completion: nil)
                }
            } else {
                // If student is saved locally but not on DB, save on DB and switch to main screen
                UserDBManager.shared.saveStudent(student) { (accountID) in
                    DispatchQueue.main.async {
                        if let accountID = accountID {
                            UserDefaults.standard.set(accountID: accountID)
                        }
                        if self.current is LoginController {
                            self.switchToMainScreen()
                        }
                    }
                }
            }
        }
    }
}
