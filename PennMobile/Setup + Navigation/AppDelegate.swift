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

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIBackgroundTaskIdentifier(_ input: UIBackgroundTaskIdentifier) -> Int {
	return input.rawValue
}

// Migrate any needed data to the group container.
// Returns whether the migration happened and succeeded.
func migrate<T: Codable>(fileName: String, of type: T.Type, from: Storage.Directory, to: Storage.Directory) -> Bool {
    if !Storage.fileExists(fileName, in: to) && Storage.fileExists(fileName, in: from) {
        do {
            let record = try Storage.retrieveThrowing(fileName, from: from, as: type)
            Storage.store(record, to: to, as: fileName)
            Storage.remove(fileName, from: from)
            return true
        } catch let error {
            print("Couldn't migrate \(fileName): \(error)")
        }
    }
    
    return false
}

// Migration of data to group container
func migrateDataToGroupContainer() {
    if migrate(fileName: Course.cacheFileName, of: [Course].self, from: .caches, to: .groupCaches) {
        print("Migrated course data.")
        WidgetKind.courseWidgets.forEach {
            WidgetCenter.shared.reloadTimelines(ofKind: $0)
        }
    }
}
