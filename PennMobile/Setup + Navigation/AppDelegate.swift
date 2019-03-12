//
//  AppDelegate.swift
//  PennMobile
//
//  Created by Josh Doman on 5/3/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseCore
import FirebaseInstanceID
import StoreKit
//import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabBarController: TabBarController!
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var rootViewController: RootViewController {
        return window!.rootViewController as! RootViewController
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if UserDefaults.standard.isNewAppVersion() {
            UserDefaults.standard.setAppVersion()
        }
        
        UserDBManager.shared.dryRun = true
        UserDBManager.shared.testRun = true
        
        FirebaseConfiguration.shared.setLoggerLevel(.min) // Comment out before release
        FirebaseApp.configure()
        
        ControllerModel.shared.prepare()
        LaundryNotificationCenter.shared.prepare()
        GSRLocationModel.shared.prepare()
        LaundryAPIService.instance.prepare {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = RootViewController()
            self.window?.makeKeyAndVisible()
        }
        
        return true
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
                    self.backgroundTask = UIBackgroundTaskIdentifier(rawValue: convertFromUIBackgroundTaskIdentifier(UIBackgroundTaskIdentifier.invalid))
                }
            }
        }
        
        DispatchQueue.main.async {
            if application.backgroundTimeRemaining > 1.0 {
                DatabaseManager.shared.endSession()
            }
            
            if let bgTask = self.backgroundTask {
                application.endBackgroundTask(bgTask)
                self.backgroundTask = UIBackgroundTaskIdentifier(rawValue: convertFromUIBackgroundTaskIdentifier(UIBackgroundTaskIdentifier.invalid))
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        DatabaseManager.shared.startSession()
        tabBarController?.reloadTabs()
        ControllerModel.shared.visibleVC().viewWillAppear(true)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        DatabaseManager.shared.endSession()
    }
    
}

extension AppDelegate: OnboardingDelegate {
    func handleFinishedOnboarding() {
    }
}

//extension AppDelegate: MessagingDelegate {
//    func application(received remoteMessage: MessagingRemoteMessage) {
//        //        print("Received data message: \(remoteMessage.appData)")
//    }
//}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID: \(messageID)")
        //        }
        
        // Print full message.
        //        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        //        let userInfo = response.notification.request.content.userInfo
        //        // Print message ID.
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID: \(messageID)")
        //        }
        //
        //        // Print full message.
        //        print(userInfo)
        
        completionHandler()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIBackgroundTaskIdentifier(_ input: UIBackgroundTaskIdentifier) -> Int {
	return input.rawValue
}
