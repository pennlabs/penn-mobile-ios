//
//  UserDefaults + Helpers.swift
//  PennMobile
//
//  Created by Josh Doman on 7/31/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation

//Mark: UserDefaultsKeys
extension UserDefaults {
    enum UserDefaultsKeys: String {
        case deviceUUID
        case deviceToken
    }
}

// Mark: Permanent DeviceUUID
extension UserDefaults {
    func setDeviceUUID(value: String) {
        set(value, forKey: UserDefaultsKeys.deviceUUID.rawValue)
        synchronize()
    }
    
    func getDeviceUUID() -> String? {
        return string(forKey: UserDefaultsKeys.deviceUUID.rawValue)
        
    }
    
    func isFirstTimeUser() -> Bool {
        return getDeviceUUID() == nil
    }
}

// Mark: Permanent Device Token (for push notifications)
extension UserDefaults {
    func setDeviceToken(value: String) {
        set(value, forKey: UserDefaultsKeys.deviceToken.rawValue)
        synchronize()
    }
    
    func getDeviceToken() -> String? {
        return string(forKey: UserDefaultsKeys.deviceToken.rawValue)
    }
}
