//
//  GSRUser.swift
//  PennMobile
//
//  Created by Josh Doman on 2/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

struct GSRUser: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    
    static func save(user: GSRUser) {
        UserDefaults.standard.setGSRUser(value: user)
    }
    
    static func hasSavedUser() -> Bool {
        return UserDefaults.standard.getGSRUser() != nil
    }
    
    static func getUser() -> GSRUser? {
        return UserDefaults.standard.getGSRUser()
    }
    
    static func clear() {
        return UserDefaults.standard.clearGSRUser()
    }
}
