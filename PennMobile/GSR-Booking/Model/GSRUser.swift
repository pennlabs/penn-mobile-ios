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
        if let account = Account.getAccount(), account.first != user.firstName {
            // Clear cache so that home title updates with new first name
            guard let homeVC = ControllerModel.shared.viewController(for: .home) as? HomeViewController else {
                return
            }
            homeVC.clearCache()
        }
        Account.update(firstName: user.firstName, lastName: user.lastName, email: user.email)
    }
    
    static func hasSavedUser() -> Bool {
        return UserDefaults.standard.getGSRUser() != nil
    }
    
    static func getUser() -> GSRUser? {
        return UserDefaults.standard.getGSRUser()
    }
    
    static func clear() {
        UserDefaults.standard.clearGSRUser()
        clearSessionID()
    }
    
    static func getSessionID() -> String? {
        let cookie = getSessionCookie()
        return cookie?.value
    }
    
    static func clearSessionID() {
        guard let cookie = getSessionCookie() else { return }
        HTTPCookieStorage.shared.deleteCookie(cookie)
        UserDefaults.standard.storeCookies()
    }
    
    static func getSessionCookie() -> HTTPCookie? {
        guard let cookies = HTTPCookieStorage.shared.cookies else { return nil }
        if let cookie = (cookies.filter { $0.name == "sessionid" }).first {
            return cookie
        } else {
            return nil
        }
    }
}
