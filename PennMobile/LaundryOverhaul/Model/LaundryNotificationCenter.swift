//
//  LaundryNotificationCenter.swift
//  PennMobile
//
//  Created by Josh Doman on 11/16/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation
import UserNotifications

class LaundryNotificationCenter {
    
    static let shared = LaundryNotificationCenter()
    
    private struct LaundryNotification: Equatable {
        let room: LaundryHall
        let isWasher: Bool
        let triggerDate: Date
        
        var identifier: String?
        
        init(room: LaundryHall, isWasher: Bool, triggerDate: Date) {
            self.room = room
            self.isWasher = isWasher
            self.triggerDate = triggerDate
        }
        
        static func ==(lhs: LaundryNotification, rhs: LaundryNotification) -> Bool {
            return lhs.room == rhs.room && lhs.isWasher == rhs.isWasher && lhs.triggerDate.minutesFrom(date: Date()) == rhs.triggerDate.minutesFrom(date: Date())
        }
    }
    
    private var pendingNotifications = [LaundryNotification]()
    
    func prepare() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func notifyWithMessage(for room: LaundryHall, isWasher: Bool, in minutes: Int, title: String?, message: String?, completion: @escaping (_ success: Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
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
                
                // Deliver the notification in five seconds.
                content.sound = UNNotificationSound.default()
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(60 * minutes),
                                                                repeats: false)
                
                // Schedule the notification.
                let identifier = "\(room.name)-\(isWasher ? "washer" : "dryer")-\(minutes)-\(Date().timeIntervalSince1970)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(request, withCompletionHandler: nil)
                
                var secondsUntilCellExpires = 60 * minutes
                
                let timesArray = isWasher ? room.remainingTimeWashers : room.remainingTimeDryers
                if timesArray.contains(minutes + 1) && !timesArray.contains(minutes - 1) {
                    secondsUntilCellExpires -= 59
                }
                
                var notification = LaundryNotification(room: room, isWasher: isWasher, triggerDate: Date().add(seconds: secondsUntilCellExpires))
                notification.identifier = identifier
                self.pendingNotifications.append(notification)
            }
            
            completion(granted)
        }
    }
    
    
    func getTimeRemainingForOutstandingNotifications(for room: LaundryHall, isWasher: Bool, timeRemainingArray: [Int], completion: @escaping ([Int]) -> Void) {
        
        var pendingNotificationTimes = pendingNotifications.filter({ (notification) -> Bool in
            return notification.room == room && notification.isWasher == isWasher
        }).map { Date().minutesFrom(date: $0.triggerDate) + 1 }
        
        var timesWithNotification = [Int]()
        for time in timeRemainingArray {
            if timesWithNotification.contains(time) {
                continue
            }
            
            if let index = pendingNotificationTimes.index(of: time) {
                timesWithNotification.append(time)
                pendingNotificationTimes.remove(at: index)
            }
        }
        
        for time in timeRemainingArray {
            if timesWithNotification.contains(time) {
                continue
            }
            
            if let index = pendingNotificationTimes.index(of: time - 1) {
                timesWithNotification.append(time)
                pendingNotificationTimes.remove(at: index)
            }
        }
        
        for time in timeRemainingArray {
            if timesWithNotification.contains(time) {
                continue
            }
            
            if let index = pendingNotificationTimes.index(of: time + 1) {
                timesWithNotification.append(time)
                pendingNotificationTimes.remove(at: index)
            }
        }
        
        completion(timesWithNotification)
    }
    
    func removeOutstandingNotification(for room: LaundryHall, isWasher: Bool, timeRemaining: Int, completion: @escaping () -> Void) {
        if let index = self.getNotificationIndex(for: room, isWasher: isWasher, timeRemaining: timeRemaining), let identifier = pendingNotifications[index].identifier {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            self.pendingNotifications.remove(at: index)
            completion()
        }
    }
    
    private func getNotificationIndex(for room: LaundryHall, isWasher: Bool, timeRemaining: Int) -> Int? {
        if let index = pendingNotifications.index(of: LaundryNotification(room: room, isWasher: isWasher, triggerDate: Date().add(minutes: timeRemaining))) {
            return index
        } else if let index = pendingNotifications.index(of: LaundryNotification(room: room, isWasher: isWasher, triggerDate: Date().add(minutes: timeRemaining - 1))) {
            return index
        } else if let index = pendingNotifications.index(of: LaundryNotification(room: room, isWasher: isWasher, triggerDate: Date().add(minutes: timeRemaining + 1))) {
            return index
        }
        return nil
    }
    
    func removeExpiredNotifications() {
        pendingNotifications = pendingNotifications.filter { $0.triggerDate > Date() }
    }
}

extension UNTimeIntervalNotificationTrigger {
    func minutesUntilTrigger() -> Int {
        if let triggerDate = nextTriggerDate() {
            return Date().minutesFrom(date: triggerDate) + 1 // adjust because automatically rounds down
        }
        return 0
    }
}

