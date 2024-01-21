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

#if canImport(WidgetKit)
import WidgetKit
#endif

import PennMobileShared

class AppDelegate: UIResponder, UIApplicationDelegate {

    var tabBarController: TabBarController!

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
    @available(*, deprecated, message: "Do not use AppDelegate as a singleton")
    static var shared: AppDelegate {
        fatalError("Could not get AppDelegate")
    }

    var rootViewController: RootViewController {
        fatalError("Could not get rootViewController")
    }
}

// Migration of data to group container
func migrateDataToGroupContainer() {
    if Storage.migrate(fileName: Course.cacheFileName, of: [Course].self, from: .caches, to: .groupCaches) {
        print("Migrated course data.")
        #if canImport(WidgetKit)
        WidgetKind.courseWidgets.forEach {
            WidgetCenter.shared.reloadTimelines(ofKind: $0)
        }
        #endif
    }

    if Storage.migrate(fileName: DiningVenue.directory, of: [DiningVenue].self, from: .caches, to: .groupCaches) {
        print("Migrated course data.")
    }

    if Storage.migrate(fileName: DiningAnalyticsViewModel.dollarHistoryDirectory, of: [DiningAnalyticsBalance].self, from: .documents, to: .groupDocuments) || Storage.migrate(fileName: DiningAnalyticsViewModel.swipeHistoryDirectory, of: [DiningAnalyticsBalance].self, from: .documents, to: .groupDocuments) {
        print("Migrated dining analytics data.")
        #if canImport(WidgetKit)
        WidgetKind.diningAnalyticsWidgets.forEach {
            WidgetCenter.shared.reloadTimelines(ofKind: $0)
        }
        #endif
    }

    if Storage.migrate(fileName: DiningAPI.favoritesCacheFileName, of: [DiningVenue].self, from: .caches, to: .groupCaches) {
       print("Migrated dining favorites data.")
        #if canImport(WidgetKit)
        WidgetKind.diningHoursWidgets.forEach {
            WidgetCenter.shared.reloadTimelines(ofKind: $0)
        }
        #endif
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
