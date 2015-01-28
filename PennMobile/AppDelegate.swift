//
//  AppDelegate.swift
//  PennMobile
//
//  Created by Vivian Huang on 7/13/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

import UIKit
import Parse
import ParseCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        application.setStatusBarStyle(UIStatusBarStyle.LightContent, animated:true);
        ParseCrashReporting.enable()
        Parse.setApplicationId("0Lczjpr6ygk2FIpBb4pcBIM8T2tGssq3QbMTsF4Z", clientKey: "YjkMxWl752Pw9wqmf8fGQ2ViTa4m5kQOcUA1L7Jv");
        PFUser.enableAutomaticUser()
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: { (valid, error) -> Void in
            // do nothing here
        })
        if application.respondsToSelector("isRegisteredForRemoteNotifications")
        {
            // iOS 8 Notifications
            //application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: (.Badge | .Sound | .Alert), categories: nil));
            var types: UIUserNotificationType = UIUserNotificationType.Badge |
                UIUserNotificationType.Alert |
                UIUserNotificationType.Sound
            
            var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
            
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
            return true
        }
        else
        {
            // iOS < 8 Notifications
            application.registerForRemoteNotificationTypes(.Badge | .Sound | .Alert)
        }
        
        var defaultACL = PFACL()
        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
        
        // Override point for customization after application launch.
        return true
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let current : PFInstallation = PFInstallation.currentInstallation();
        current.setDeviceTokenFromData(deviceToken);
        current.save();
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo);
    }
    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
        if (currentInstallation.badge != 0)
        {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

