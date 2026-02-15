//
//  LaundryNotificationCenter.swift
//  PennMobile
//
//  Created by Josh Doman on 11/16/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation
import UserNotifications
import PennMobileShared
#if canImport(ActivityKit)
import ActivityKit
#endif

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
        
        // Dismiss any existing laundry live activities that have ended
        Activity<MachineData>.activities.forEach { activity in
            if activity.attributes.dateComplete <= now {
                Task {
                    await activity.end(using: nil, dismissalPolicy: .immediate)
                }
            }
        }
        
        let status: MachineDetail.Status = switch machine.status {
        case .offline: .unavailable
        case .open: .available
        case .outOfOrder: .unknown
        case .running: .inUse
        }
        
        let detail = MachineDetail(
            id: String(machine.id),
            type: machine.isWasher ? .washer : .dryer,
            status: status,
            timeRemaining: machine.timeRemaining
        )
        
        _ = try? Activity.request(attributes: MachineData(hallName: machine.roomName, machine: detail, dateComplete: now.add(minutes: minutes)), contentState: MachineData.ContentState())
        
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
        
        Activity<MachineData>.activities.forEach { activity in
            if activity.attributes.machine.id == String(machine.id) {
                Task {
                    await activity.end(using: nil, dismissalPolicy: .immediate)
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
