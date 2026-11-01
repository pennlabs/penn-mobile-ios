//
//  NotificationDeviceTokenManager.swift
//  PennMobile
//
//  Created by Anthony Li on 11/18/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import PennMobileShared

class NotificationDeviceTokenManager {
    
    static var cachedNotificationTokenKey: String = "PennMobileNotificationKey"
    
    static let store = UserDefaults(suiteName: "group.org.pennlabs.PennMobile")
    
    static func newNotificationTokenReceived(_ token: Data) async {
        let cached: Data? = Self.store?.data(forKey: Self.cachedNotificationTokenKey)
        
        if let cached {
            guard token != cached else { return }
            
            await PennMobileApplication.Notifications.DeleteDeviceToken(token: cached).execute(shouldSilentlyFail: true)
            Self.store?.removeObject(forKey: Self.cachedNotificationTokenKey)
        }
        
        await PennMobileApplication.Notifications.UploadDeviceToken(
            token: token,
            isDev: false).execute(shouldSilentlyFail: true)
        Self.store?.set(token, forKey: Self.cachedNotificationTokenKey)
    }
    
    static func deleteStoredNotificationToken() async {
        guard let cached = Self.store?.data(forKey: Self.cachedNotificationTokenKey) else { return }
        
        await PennMobileApplication.Notifications.DeleteDeviceToken(token: cached).execute()
        Self.store?.removeObject(forKey: Self.cachedNotificationTokenKey)
    }
}
