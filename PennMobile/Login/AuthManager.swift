//
//  AuthManager.swift
//  PennMobile
//
//  Created by Anthony Li on 9/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

enum AuthState: Equatable {
    case notDetermined
    case loggedOut
    case guest
    case loggedIn(Account)
}

class AuthManager: ObservableObject {
    @Published private(set) var state = AuthState.notDetermined

    static func shouldRequireLogin() -> Bool {
        if !Account.isLoggedIn {
            // User is not logged in
            return true
        }

        guard let lastLogin = UserDefaults.standard.getLastLogin() else {
            return true
        }

        let now = Date()
        let components = Calendar.current.dateComponents([.year], from: now)
        let january = Calendar.current.date(from: components)!
        let june = january.add(months: 5)
        let august = january.add(months: 7)

        if january <= now && now <= june {
            // Last logged in before current Spring Semester -> Require new log in
            return lastLogin < january
        } else if now >= august {
            // Last logged in before current Fall Semester -> Require new log in
            return lastLogin < august
        } else {
            return false
        }
    }

    static func clearAccountData() {
        HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
        UserDefaults.standard.clearAll()
        OAuth2NetworkManager.instance.clearRefreshToken()
        OAuth2NetworkManager.instance.clearCurrentAccessToken()
        Account.clear()
    }

    func determineInitialState() {
        if AuthManager.shouldRequireLogin() {
            if case .guest = state {
                state = .guest
            } else {
                if !Account.isLoggedIn {
                    AuthManager.clearAccountData()
                }
                state = .loggedOut
            }
        } else {
            state = .loggedIn(Account.getAccount()!)
        }
    }

    func enterGuestMode() {
        guard case .loggedOut = state else {
            fatalError("Cannot enter guest mode from \(state)")
        }

        state = .guest
    }
    
    func logOut() {
        state = .loggedOut
        AuthManager.clearAccountData()
    }
}
