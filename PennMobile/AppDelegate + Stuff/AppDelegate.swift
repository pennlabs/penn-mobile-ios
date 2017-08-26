//
//  AppDelegate.swift
//  PennMobile
//
//  Created by Josh Doman on 5/3/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var swRevealViewController: SWRevealViewController!
    private var navController: UINavigationController!
    private var masterTableViewController = MasterTableViewController()
    private var homeController = ControllerSettings.shared.firstController
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        DatabaseManager.shared.dryRun = true
        //DatabaseManager.shared.startSession() //adds new session log to queue
        
        GoogleAnalyticsManager.prepare()
        
        navController = UINavigationController(rootViewController: homeController)
        navController.isNavigationBarHidden = true
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        presentSWController()
        //registerForPushNotifications() //uncomment when ready to start registering tokens for push notifications
            
        return true
    }
    
    private func presentSWController() {
        
        let masterNavController = UINavigationController(rootViewController: masterTableViewController)
        let homeNavController = UINavigationController(rootViewController: homeController)
        
        swRevealViewController = SWRevealViewController(rearViewController: masterNavController, frontViewController: homeNavController)
        
        self.navController.pushViewController(swRevealViewController, animated: false)
        
        masterTableViewController.prepare() //need to call because viewDidLoad not called until menu button is pressed (bug with SWRevealViewController?)
    }
    
    //Special thanks to Ray Wenderlich
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            guard granted else {
                self.registerOrUpdateUser()
                return
            }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                self.registerOrUpdateUser()
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        registerOrUpdateUser(with: token)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
        registerOrUpdateUser()
    }
    
    private func registerOrUpdateUser(with token: String? = nil) {
        do {
            if try DatabaseManager.shared.createUser(with: token) { //returns true if first visit
                DatabaseManager.shared.startSession()
            } else if let token = token {
                try DatabaseManager.shared.updateDeviceToken(with: token)
            }
        } catch {
            print("Caught: \(error)")
        }
    }
    
    var backgroundTask: UIBackgroundTaskIdentifier?
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if DatabaseManager.shared.dryRun { return }
        
        DatabaseManager.shared.endSession()
        backgroundTask = application.beginBackgroundTask {
            if let bgTask = self.backgroundTask {
                DispatchQueue.main.async {
                    application.endBackgroundTask(bgTask)
                    self.backgroundTask = UIBackgroundTaskInvalid
                }
            }
        }
        
        DispatchQueue.main.async {
            if application.backgroundTimeRemaining > 1.0 {
                DatabaseManager.shared.endSession()
            }
            
            if let bgTask = self.backgroundTask {
                application.endBackgroundTask(bgTask)
                self.backgroundTask = UIBackgroundTaskInvalid
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        DatabaseManager.shared.startSession()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        DatabaseManager.shared.endSession()
    }

}

