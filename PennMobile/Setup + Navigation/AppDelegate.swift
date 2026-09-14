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
import PennMobileShared

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
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
    
    func applicationWillTerminate(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
}

// Global access of rootview to handle navigations
extension AppDelegate {
    @available(*, deprecated, message: "Do not use AppDelegate as a singleton")
    static var shared: AppDelegate {
        fatalError("Could not get AppDelegate")
    }
}

/// One-time removal of the JSON files the old `Storage` cache left behind.
///
/// Dining data and courses are fetched on demand now. Two things are worth carrying
/// over first, because their widgets can't fetch for themselves: the user's favorite
/// venues and the last set of courses.
func cleanUpLegacyCacheFiles() {
    let didCleanUpKey = "didCleanUpLegacyCacheFiles"
    guard !UserDefaults.standard.bool(forKey: didCleanUpKey) else { return }

    let fileManager = FileManager.default
    let groupContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: UserDefaults.appGroupID)
    let containers = [
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first,
        groupContainer?.appendingPathComponent("Documents"),
        groupContainer?.appendingPathComponent("Library/Caches")
    ].compactMap { $0 }

    let legacyFavoriteIDsFile = "diningVenue-v2-favorites.json"
    let legacyFavoriteVenuesFile = "diningFavoritesCache"
    let legacyCoursesFile = "coursesCache"
    let legacyFiles = [
        legacyFavoriteIDsFile,
        legacyFavoriteVenuesFile,
        legacyCoursesFile,
        "diningVenue-v2.json",
        "diningMenus.json",
        "diningBalance.json",
        "diningAnalyticsDollarData",
        "diningAnalyticsSwipeData",
        "diningAnalyticsPlanStartDate"
    ]

    func legacyData(_ fileName: String) -> Data? {
        for container in containers {
            if let data = try? Data(contentsOf: container.appendingPathComponent(fileName)) {
                return data
            }
        }
        return nil
    }

    if DiningAPI.instance.favoriteVenueIDs.isEmpty {
        if let data = legacyData(legacyFavoriteIDsFile), let ids = try? JSONDecoder().decode([Int].self, from: data), !ids.isEmpty {
            DiningAPI.instance.favoriteVenueIDs = ids
        } else if let data = legacyData(legacyFavoriteVenuesFile), let venues = try? JSONDecoder().decode([DiningVenue].self, from: data), !venues.isEmpty {
            DiningAPI.instance.favoriteVenueIDs = venues.map(\.id)
        }
    }

    if UserDefaults.group.data(forKey: Course.cacheKey) == nil, let data = legacyData(legacyCoursesFile) {
        UserDefaults.group.set(data, forKey: Course.cacheKey)
    }

    for container in containers {
        for file in legacyFiles {
            try? fileManager.removeItem(at: container.appendingPathComponent(file))
        }
    }

    UserDefaults.standard.clearDiningBalance()
    UserDefaults.standard.set(true, forKey: didCleanUpKey)

    (WidgetKind.diningHoursWidgets + WidgetKind.courseWidgets).forEach {
        WidgetCenter.shared.reloadTimelines(ofKind: $0)
    }
}
