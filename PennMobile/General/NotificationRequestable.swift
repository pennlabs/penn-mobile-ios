//
//  NotificationRequestable.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UserNotifications
import SCLAlertView

protocol NotificationRequestable {}

extension NotificationRequestable where Self: UIViewController {
    
    internal typealias AuthorizedCompletion = (_ granted: Bool) -> Void
    
    func requestNotification (_ completion: AuthorizedCompletion? = nil) {
        
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                DispatchQueue.main.async {
                    self.alertForDetermination(completion)
                }
            }
            
            if settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    self.alertForDecline(completion)
                }
            }
            
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    completion?(true)
                }
            }
        })
    }
    
    func registerPushNotification(_ completion: AuthorizedCompletion?) {
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
            completion?(granted)
        }
    }
    
    func alertForDecline(_ completion: AuthorizedCompletion?) {
        let alertView = SCLAlertView()
        alertView.addButton("Allow") {
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    // Checking for setting is opened or not
                    print("Setting is opened: \(success)")
                    DispatchQueue.main.async {
                        completion?(success)
                    }
                })
            }
        }
        alertView.showSuccess("Turn On Notifications", subTitle: "Go to Settings -> PennMobile -> Notification -> Turn On Notifications")
    }
    
    func alertForDetermination(_ completion: AuthorizedCompletion?) {
        let alertView = SCLAlertView()
        alertView.addButton("Turn On"){
            self.registerPushNotification(completion)
        }
        alertView.showSuccess("Enable Notifications", subTitle: "Get notifications for laundry, and our future updates!")
    }
    
}

