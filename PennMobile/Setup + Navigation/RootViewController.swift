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
class RootViewController: UIViewController, NotificationRequestable {
    private var current: UIViewController
    
    private var lastLoginAttempt: Date?
    
    // Fetch transactions even if hasDiningPlan() returns FALSE
    fileprivate let fetchTransactionsForUsersWithoutDiningPlan = true
    
    init() {
        self.current = SplashViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.isNewAppVersion() {
            UserDefaults.standard.setAppVersion()
            // Save laundry rooms with account ID (available starting in 6.1)
            if let rooms = UserDefaults.standard.getLaundryPreferences() {
                UserDBManager.shared.saveLaundryPreferences(for: rooms)
            }
        }
                        
        if shouldRequireLogin() {
            // Logged in and should require login
            clearAccountData()
        }
        
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
        
        UserDefaults.standard.restoreCookies()
        
        self.applicationWillEnterForeground()
    }
    
    func applicationWillEnterForeground() {
        if self.current is HomeNavigationController {
            if Account.isLoggedIn && shouldRequireLogin() {
                // If user is logged in but login is required, clear user data and switch to logout
                clearAccountData()
                self.switchToLogout()
            } else if !Account.isLoggedIn {
                // If user is not logged in, switch to logout but don't clear user data
                self.switchToLogout()
            } else {
                // Refresh current VC
                ControllerModel.shared.visibleVC().viewWillAppear(true)
            }
        }
        
        // If student is in Wharton but does not have a session ID, retrieve one if possible
        if UserDefaults.standard.isInWharton() && GSRUser.getSessionID() == nil {
            let now = Date()
            if lastLoginAttempt != nil && lastLoginAttempt!.minutesFrom(date: now) < 720 {
                // Don't try to auto re-login if it's been less than 12 hours since last attempt
                return
            }
            self.lastLoginAttempt = Date()
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
        
        // Fetch transaction data at least once a week, starting on Sundays
        if shouldFetchTransactions() {
            if UserDefaults.standard.isAuthedIn() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    PennCashNetworkManager.instance.getTransactionHistory { data in
                        if let data = data, let str = String(bytes: data, encoding: .utf8) {
                            UserDBManager.shared.saveTransactionData(csvStr: str)
                            UserDefaults.standard.setLastTransactionRequest()
                        }
                    }
                }
            }
        }
        
        // Send saved unsent events
        FeedAnalyticsManager.shared.sendSavedEvents()
        
        // Refresh push notification device token if authorized and not in simulator
        #if !targetEnvironment(simulator)
            updatePushNotificationToken()
        #endif
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
    
    func switchToLogout() {
        let loginController = LoginController()
        animateDismissTransition(to: loginController)
        
        // Clear cache so that home title updates with new first name
        guard let homeVC = ControllerModel.shared.viewController(for: .home) as? HomeViewController else {
            return
        }
        homeVC.clearCache()
    }
    
    fileprivate func clearAccountData() {
        HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
        UserDefaults.standard.clearAll()
        OAuth2NetworkManager.instance.clearRefreshToken()
        Account.clear()
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

// MARK: - Require Login
extension RootViewController {
    func shouldRequireLogin() -> Bool {
        if !OAuth2NetworkManager.instance.hasRefreshToken() {
            // User is not logged in
            return true
        }
        
        guard let lastLogin = UserDefaults.standard.getLastLogin() else {
            return true
        }
        
        let now = Date()
        let components = Calendar.current.dateComponents([.year], from: now)
        let january = Calendar.current.date(from: components)!
        let june = january.add(months: 5)
        let august = january.add(months: 7)
        
        if january <= now && now <= june {
            // Last logged in before current Spring Semester -> Require new log in
            return lastLogin < january
        } else if now >= august {
            // Last logged in before current Fall Semester -> Require new log in
            return lastLogin < august
        } else {
            return false
        }
    }
}

// MARK: - Update Transactions
extension RootViewController {
    func shouldFetchTransactions() -> Bool {
        if !OAuth2NetworkManager.instance.hasRefreshToken() || !UserDefaults.standard.hasDiningPlan() {
            // User is not logged in or does not have a dining plan
            return false
        }
        
        guard let lastTransactionRequest = UserDefaults.standard.getLastTransactionRequest() else {
            // No transactions fetched yet, so return false
            return true
        }
        
        let now = Date()
        let diffInDays = Calendar.current.dateComponents([.day], from: lastTransactionRequest, to: now).day
        if let diff = diffInDays, diff >= 7 {
            // More than a week since last update
            return true
        } else {
            // Return true if today is Sunday and transactions have not yet been fetched today
            return now.integerDayOfWeek == 0 && !lastTransactionRequest.isToday
        }
    }
}
