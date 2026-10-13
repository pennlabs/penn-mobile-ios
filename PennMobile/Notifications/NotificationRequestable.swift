//
//  NotificationRequestable.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

protocol NotificationRequestable {}

extension NotificationRequestable {

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
    func updatePushNotificationToken() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .authorized {
                self.registerPushNotification()
            }
        })
    }

    func registerPushNotification(_ completion: AuthorizedCompletion? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, _) in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                completion?(granted)
            }
        }
    }

    func alertForDecline(_ completion: AuthorizedCompletion?) {
        let alertController = UIAlertController(title: "Turn On Notifications", message: "Go to Settings -> PennMobile -> Notification -> Turn On Notifications", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: nil))
        let allowAction = UIAlertAction(title: "Allow", style: .default, handler: { (_) in
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
        })
        alertController.addAction(allowAction)
        alertController.preferredAction = allowAction
        presentAlert(alertController)
    }

    func alertForDetermination(_ completion: AuthorizedCompletion?) {
        let alertController = UIAlertController(title: "Enable Notifications", message: "Receive monthly dining plan progress updates, laundry alerts, and information about new features.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: nil))
        let turnOnAction = UIAlertAction(title: "Turn On", style: .default, handler: { (_) in
            self.registerPushNotification(completion)
        })
        alertController.addAction(turnOnAction)
        alertController.preferredAction = turnOnAction
        presentAlert(alertController)
    }

    // Presents from the topmost view controller, since conformers aren't necessarily view controllers
    private func presentAlert(_ alertController: UIAlertController) {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        let window = scene?.windows.first { $0.isKeyWindow } ?? scene?.windows.first

        var presenter = window?.rootViewController
        while let presented = presenter?.presentedViewController, !presented.isBeingDismissed {
            presenter = presented
        }
        presenter?.present(alertController, animated: true, completion: nil)
    }

}
