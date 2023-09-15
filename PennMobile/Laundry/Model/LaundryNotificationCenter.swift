//
//  LaundryNotificationCenter.swift
//  PennMobile
//
//  Created by Josh Doman on 11/16/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation
import UserNotifications
import ActivityKit

class LaundryNotificationCenter {

    static let shared = LaundryNotificationCenter()

    private var identifiers = [LaundryMachine: String]()

    func prepare() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func notifyWithMessage(for machine: LaundryMachine, title: String?, message: String?, completion: @escaping (_ success: Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        let minutes = machine.timeRemaining
        let now = Date()
        
        if #available(iOS 16.1, *) {
            // Dismiss any existing laundry live activities that have ended
            Activity<LaundryAttributes>.activities.forEach { activity in
                if activity.attributes.dateComplete <= now {
                    Task {
                        await activity.end(using: nil, dismissalPolicy: .immediate)
                    }
                }
            }
            
            _ = try? Activity.request(attributes: LaundryAttributes(machine: machine, dateComplete: now.add(minutes: minutes)), contentState: LaundryAttributes.ContentState())
        }
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if error != nil {
                completion(false)
                return
            }

            if granted {
                let content = UNMutableNotificationContent()
                if let title = title {
                    content.title = NSString.localizedUserNotificationString(forKey:
                        title, arguments: nil)
                }
                if let message = message {
                    content.body = NSString.localizedUserNotificationString(forKey:
                        message, arguments: nil)
                }

                // Deliver the notification when minutes expire.
                content.sound = UNNotificationSound.default
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(60 * minutes),
                                                                repeats: false)

                // Schedule the notification.
                let identifier = "\(machine.hashValue)-\(Date().timeIntervalSince1970)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(request, withCompletionHandler: nil)

                self.identifiers[machine] = identifier
            }

            completion(granted)
        }
    }

    func updateForExpiredNotifications(_ completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            var newIdentifiers = [LaundryMachine: String]()
            for (machine, identifier) in self.identifiers {
                if requests.contains(where: { (request) -> Bool in
                    request.identifier == identifier
                }) {
                    newIdentifiers[machine] = identifier
                }
            }
            self.identifiers = newIdentifiers
            completion()
        }
    }

    func removeOutstandingNotification(for machine: LaundryMachine) {
        guard let identifier = identifiers[machine] else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        identifiers.removeValue(forKey: machine)
        
        if #available(iOS 16.1, *) {
            Activity<LaundryAttributes>.activities.forEach { activity in
                if activity.attributes.machine.id == machine.id {
                    Task {
                        await activity.end(using: nil, dismissalPolicy: .immediate)
                    }
                }
            }
        }
    }

    func isUnderNotification(for machine: LaundryMachine) -> Bool {
        return identifiers[machine] != nil
    }
}

extension LaundryMachine {
    func isUnderNotification() -> Bool {
        return LaundryNotificationCenter.shared.isUnderNotification(for: self)
    }
}
