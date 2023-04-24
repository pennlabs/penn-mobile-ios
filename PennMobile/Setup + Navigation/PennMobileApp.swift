//
//  App.swift
//  PennMobile
//
//  Created by Anthony Li on 4/23/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

@main
struct PennMobileApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    @State var authCoordinator: AuthCoordinator = {
        if Account.isLoggedIn {
            if shouldRequireLogin() {
                clearAccountData()
                return AuthCoordinator(initialAuthState: .loggingIn)
            } else {
                return AuthCoordinator(initialAuthState: .authenticated)
            }
        } else {
            return AuthCoordinator(initialAuthState: .loggingIn)
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authCoordinator)
        }
    }
}

func shouldRequireLogin() -> Bool {
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

func clearAccountData() {
    HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
    UserDefaults.standard.clearAll()
    OAuth2NetworkManager.instance.clearRefreshToken()
    OAuth2NetworkManager.instance.clearCurrentAccessToken()
    Account.clear()
}
