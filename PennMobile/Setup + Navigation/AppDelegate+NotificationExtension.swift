//
//  AppDelegate+NotificationExtension.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/14/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Identifiers for notification actions and categories
    struct NotificationIdentifiers {
        // Actions - these are the "buttons" you can press on notifications
        static let cancelGSRAction = "CANCEL_GSR_ACTION"
        static let shareGSRAction = "SHARE_GSR_ACTION"
        
        // Categories - these are the types of notifications (this string also embedded in the payload)
        static let upcomingGSRCategory = "UPCOMING_GSR"
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        UserDBManager.shared.savePushNotificationDeviceToken(deviceToken: token)
        
        // Setup rich notification categories
        let cancelGSRBookingAction = UNNotificationAction(identifier: NotificationIdentifiers.cancelGSRAction, title: "Cancel Booking", options: [.foreground])
        let shareGSRBookingAction = UNNotificationAction(identifier: NotificationIdentifiers.shareGSRAction, title: "Share", options: [.foreground])

        let upcomingGSRCategory = UNNotificationCategory(
            identifier: NotificationIdentifiers.upcomingGSRCategory,
            actions: [cancelGSRBookingAction, shareGSRBookingAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "Upcoming GSR",
            options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([upcomingGSRCategory])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo

        if let aps = userInfo["aps"] as? [String: AnyObject] {
            if response.actionIdentifier == NotificationIdentifiers.cancelGSRAction {
                // TODO: cancel the gsr
                dump(aps)
            } else if response.actionIdentifier == NotificationIdentifiers.shareGSRAction {
                // TODO: share the gsr
                dump(aps)
            }
        }
        completionHandler()
    }
}
