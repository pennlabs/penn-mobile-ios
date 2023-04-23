//
//  AppDelegate.swift
//  PennMobile
//
//  Created by Josh Doman on 5/3/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import StoreKit
import SwiftUI
import WidgetKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabBarController: TabBarController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.set(gsrGroupsEnabled: false)

        #if DEBUG
            FirebaseConfiguration.shared.setLoggerLevel(.min)
            UserDefaults.standard.set(gsrGroupsEnabled: true)
        #endif

        // Register to receive delegate actions from rich notifications
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()

        FirebaseApp.configure()
        ControllerModel.shared.prepare()
        LaundryNotificationCenter.shared.prepare()
        GSRLocationModel.shared.prepare()
        LaundryAPIService.instance.prepare {}
        UserDBManager.shared.loginToBackend()

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = RootViewController()
        self.window?.makeKeyAndVisible()

        migrateDataToGroupContainer()

        return true
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

    var backgroundTaskID: UIBackgroundTaskIdentifier?

    func applicationDidEnterBackground(_ application: UIApplication) {
        sendLogsToServer()
    }

    private func sendLogsToServer() {
        if FeedAnalyticsManager.shared.dryRun { return }

        // Perform the task on a background queue.
        DispatchQueue.global().async {
            // Request the task assertion and save the ID.
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Send Logs Task") {
                // End the task if time expires.
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
            }

            // Save the logs
            FeedAnalyticsManager.shared.save()

            // Send the data synchronously.
            FeedAnalyticsManager.shared.sendEvents()

            // Remove the logs since they have been sent
            FeedAnalyticsManager.shared.removeSavedEvents()

            // End the task assertion.
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        rootViewController.applicationWillEnterForeground()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
}

extension AppDelegate: OnboardingDelegate {
    func handleFinishedOnboarding() {
    }
}

// Global access of rootview to handle navigations
extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    var rootViewController: RootViewController {
        return window!.rootViewController as! RootViewController
    }
}

// Migration of data to group container
func migrateDataToGroupContainer() {
    if Storage.migrate(fileName: Course.cacheFileName, of: [Course].self, from: .caches, to: .groupCaches) {
        print("Migrated course data.")
        WidgetKind.courseWidgets.forEach {
            WidgetCenter.shared.reloadTimelines(ofKind: $0)
        }
    }

    if Storage.migrate(fileName: DiningAnalyticsViewModel.dollarHistoryDirectory, of: [DiningAnalyticsBalance].self, from: .documents, to: .groupDocuments) || Storage.migrate(fileName: DiningAnalyticsViewModel.swipeHistoryDirectory, of: [DiningAnalyticsBalance].self, from: .documents, to: .groupDocuments) {
        print("Migrated dining analytics data.")
        WidgetKind.diningAnalyticsWidgets.forEach {
            WidgetCenter.shared.reloadTimelines(ofKind: $0)
        }
    }

    // Migrate dining balances if a dining balance file doesn't already exist.
    if let diningBalance = (UserDefaults.standard as SwiftCompilerSilencing).getDiningBalance() {
        if !Storage.fileExists(DiningBalance.directory, in: .groupCaches) {
            Storage.store(diningBalance, to: .groupCaches, as: DiningBalance.directory)
        }
        UserDefaults.standard.clearDiningBalance()
    }
}

private protocol SwiftCompilerSilencing {
    func getDiningBalance() -> DiningBalance?
}

extension UserDefaults: SwiftCompilerSilencing {}
