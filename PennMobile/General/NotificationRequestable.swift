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
                    UIApplication.shared.registerForRemoteNotifications()
                    completion?(true)
                }
            }
        })
    }
    
    // Refreshes device token if authorization has already been granted
    func registerPushNotificationsIfAuthorized(_ completion: AuthorizedCompletion? = nil) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .authorized {
                self.registerPushNotification(completion)
            } else {
                completion?(false)
            }
        })
    }
    
    func registerPushNotification(_ completion: AuthorizedCompletion?) {
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                completion?(granted)
            }
        }
    }
    
    func alertForDecline(_ completion: AuthorizedCompletion?) {
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Allow") {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    // Checking for setting is opened or not
                    DispatchQueue.main.async {
                        completion?(success)
                    }
                })
            }
        }
        alertView.addButton("Decline", backgroundColor: UIColor(r: 114, g: 115, b: 117), action: {  })
        alertView.showSuccess("Turn On Notifications", subTitle: "Go to Settings -> PennMobile -> Notification -> Turn On Notifications")
    }
    
    func alertForDetermination(_ completion: AuthorizedCompletion?) {
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Turn On") {
            self.registerPushNotification(completion)
        }
        alertView.addButton("Decline", backgroundColor: UIColor(r: 114, g: 115, b: 117), action: {  })
        alertView.showSuccess("Enable Notifications", subTitle: "Receive monthly dining plan progress updates, laundry alerts, and information about new features.")
    }
    
}

