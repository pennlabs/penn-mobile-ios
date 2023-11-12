//
//  RootViewController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/25/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import StoreKit
import SwiftyJSON

// Source: https://medium.com/@stasost/ios-root-controller-navigation-3625eedbbff
class RootViewController: UIViewController, NotificationRequestable, ShowsAlert {
    var current: UIViewController

    private var lastLoginAttempt: Date?

    // Fetch transactions even if hasDiningPlan() returns FALSE
    fileprivate let fetchTransactionsForUsersWithoutDiningPlan = true

    init() {
        self.current = UIViewController()
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.isNewAppVersion() {
            UserDefaults.standard.setAppVersion()
        }

        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)

        if #available(iOS 15, *) {
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: URL(string: "https://itunes.apple.com/lookup?bundleId=org.pennlabs.PennMobile")!),
                   let data = try? JSON(data: data),
                   let version = data["results"][0]["version"].string,
                   let minimumOsVersion = data["results"][0]["minimumOsVersion"].int {
                    let appVersion = UserDefaults.standard.getAppVersion()
                    if appVersion.versionCompare(version) == .orderedAscending {
                        showOption(withMsg: "New version of PennMobile available for iOS version greater than \(minimumOsVersion). The app may not be fully functional on older versions.", title: "Update available", onAccept: {
                            guard let url = URL(string: "itms-apps://apps.apple.com/us/app/penn-mobile/id944829399") else { return }
                            UIApplication.shared.open(url)
                        }, onCancel: {
                            self.applicationWillEnterForeground()
                        })
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.applicationWillEnterForeground()
                        }
                    }
                } else {
                    // No network request, simply go to home
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.applicationWillEnterForeground()
                    }
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.applicationWillEnterForeground()
            }
        }
    }

    func applicationWillEnterForeground() {
        if Account.isLoggedIn && shouldRequireLogin() {
            // If user is logged in but login is required, clear user data and switch to logout
            clearAccountData()
            switchToLogout()
            return
        } else if !Account.isLoggedIn {
            // If user is not logged in, switch to logout but don't clear user data
            switchToLogout()
            return
        } else {
            // Refresh current VC
            UserDefaults.standard.restoreCookies()
            switchToMainScreen()
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

        UserDBManager.shared.getWhartonStatus { result in
            if let isWharton = try? result.get() {
                UserDefaults.standard.set(isInWharton: isWharton)
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
    }

    func showMainScreen() {
    }

    func switchToMainScreen() {
        // Keep track locally of app sessions (for app review prompting)
        let sessionCount = UserDefaults.standard.integer(forKey: "launchCount")
        UserDefaults.standard.set(sessionCount+1, forKey: "launchCount")
        UserDefaults.standard.synchronize()

        // This code will ONLY present the review if we're not running Fastlane UI Automation (for screenshots)
        if !UIApplication.isRunningFastlaneTest {
            if sessionCount == 3 {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }

    func switchToLogout() {
    }

    func clearAccountData() {
        HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
        UserDefaults.standard.clearAll()
        OAuth2NetworkManager.instance.clearRefreshToken()
        OAuth2NetworkManager.instance.clearCurrentAccessToken()
        Account.clear()
    }

    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        current.willMove(toParent: nil)
        addChild(new)

        transition(from: current, to: new, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
        }) { _ in
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
        }) { _ in
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
        if !Account.isLoggedIn {
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
        if !Account.isLoggedIn || !UserDefaults.standard.hasDiningPlan() {
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

// MARK: - Anon. Course Data
extension RootViewController {
    func shouldRequestCoursePermission() -> Bool {
        if UserDefaults.standard.getPreference(for: .anonymizedCourseSchedule) {
            // We already have permission, no need to ask.
            return false
        }

        guard Account.isLoggedIn, let account = Account.getAccount(), account.isStudent else {
            // User is not logged in or user is logged in but not a student, no need to ask
            return false
        }

        if let lastRequest = UserDefaults.standard.getLastDidAskPermission(for: .anonymizedCourseSchedule) {
            let months = Calendar.current.dateComponents([.month], from: lastRequest, to: Date()).month!
            // More than a 6 months since last request. Time to ask again.
            return months >= 6
        } else {
            // Have not yet asked. Request away!
            return true
        }
    }

    func shouldShareCourses() -> Bool {
        guard Account.isLoggedIn && UserDefaults.standard.getPreference(for: .anonymizedCourseSchedule) else {
            // We do not have permission to share courses or the user is not logged in
            return false
        }

        if let lastShareDate = UserDefaults.standard.getLastShareDate(for: .anonymizedCourseSchedule) {
            // Save updated course schedule if it's been more than 1 week since last save
            let diffInDays = Calendar.current.dateComponents([.day], from: lastShareDate, to: Date()).day!
            return diffInDays >= 7
        } else {
            // Courses have never been shared. Do so now.
            return true
        }
    }
}
