//
//  AppDelegate+NotificationExtension.swift
//  PennMobile
//
//  Created by Dominic Holmes on 2/14/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

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
        Task {
            await NotificationDeviceTokenManager.shared.tokenReceived(deviceToken)
        }

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

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        if (try? await URLSession.shared.data(from: URL(string: "https://pennmobile.org/api/")!)) != nil {
            return .newData
        } else {
            return .failed
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo

        // GSR Notification
        if response.notification.request.content.categoryIdentifier == NotificationIdentifiers.upcomingGSRCategory,
            let gsrReservation = userInfo["reservation"] as? [String: String] {
            if response.actionIdentifier == NotificationIdentifiers.cancelGSRAction, let bookingID = gsrReservation["booking_id"] {

                FirebaseAnalyticsManager.shared.trackEvent(action: "GSR Delete From Notification", result: "User Deleted GSR From Notification", content: "User Deleted GSR From Notification")

                // This makes the rootVC go to home screen
                rootViewController.showMainScreen()
                // We use HomeVC's "delete res" method
                guard let homeVC = ControllerModel.shared.viewController(for: .home) as? HomeViewController else { return }
                homeVC.deleteReservation(bookingID)

            } else if response.actionIdentifier == NotificationIdentifiers.shareGSRAction, let roomName = gsrReservation["room_name"], let startDateString = gsrReservation["start"], let endDateString = gsrReservation["end"] {

                FirebaseAnalyticsManager.shared.trackEvent(action: "GSR Share From Notification", result: "User Shared GSR From Notification", content: "User Shared GSR From Notification")

                // Share the GSR Booking with the iOS share sheet
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

                var text = "Upcoming GSR in \(roomName) "
                if let startDate = dateFormatter.date(from: startDateString), let endDate = dateFormatter.date(from: endDateString) {
                    if startDate.isToday {
                        text += "today "
                    } else {
                        dateFormatter.dateFormat = "EEEE"
                        text += "\(dateFormatter.string(from: startDate)) "
                    }
                    dateFormatter.dateFormat = "h:mm a"
                    text += "from \(dateFormatter.string(from: startDate)) to \(dateFormatter.string(from: endDate))"
                }
                let randomEmojis = ["💖", "🔥", "🤠", "💙", "💚", "💛", "💜", "🥰", "🦑", "🥴", "🤩", "😎", "🤓", "😍"]
                text += ". Booked by Penn Mobile \(randomEmojis.random ?? "💖")"

                let textToShare = [text]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.rootViewController.view
                // exclude some activity types from the list (optional)
                activityViewController.excludedActivityTypes = [ .airDrop ]
                self.rootViewController.present(activityViewController, animated: true, completion: nil)
            }
        }

        completionHandler()
    }
}
