//
//  NotificationService.swift
//  GSRNotificationServiceExtension
//
//  Created by Dominic Holmes on 3/5/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        defer {
            contentHandler(bestAttemptContent ?? request.content)
        }

        // Category identifiers are defined in AppDelegate+NotificationExtension.swift
        if request.content.categoryIdentifier == "UPCOMING_GSR" {
            if let reservation = request.content.userInfo["reservation"] as? [String: String],
                let urlString = reservation["image_url"] {

                // Create an image attachment by downloading the image at specified URL
                if let attachment = request.getImageAttachment(with: urlString) {
                    bestAttemptContent?.attachments = [attachment]
                }
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
