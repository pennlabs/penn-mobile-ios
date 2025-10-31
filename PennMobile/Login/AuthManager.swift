//
//  AuthManager.swift
//  PennMobile
//
//  Created by Anthony Li on 9/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import LabsPlatformSwift
import PennMobileShared

enum AuthState: Equatable {
    case loggedOut
    case guest
    case loggedIn(Account)
    
    var isLoggedIn: Bool {
        if case .loggedIn = self {
            return true
        }
        
        return false
    }
}

@MainActor
class AuthManager: ObservableObject {
    @Published private(set) var state = AuthState.loggedOut

    static func shouldRequireLogin() -> Bool {
        guard let lastLogin = UserDefaults.standard.getLastLogin(), Account.current != nil else {
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

        // We should require a new login if the last login took place prior to this semester
        if january <= now && now <= june { // If we're in the Spring semester
            return lastLogin < january
        } else if now >= august { // If we're in the Fall semester
            return lastLogin < august
        } else {
            return false
        }
    }

    static func clearAccountData() {
        HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
        UserDefaults.standard.clearAll()
        Account.clear()
    }
    
    @MainActor func handlePlatformLogin(res: Bool) async {
        guard res else {
            self.state = .loggedOut
            FirebaseAnalyticsManager.shared.trackEvent(action: "Attempt Login", result: "Failed Login", content: "Failed on Platform")
            return
        }
        
        UserDefaults.standard.setLastLogin()
        
        // Update account if able, else just default to the one we have
        // (which is just the initial value of Account.current)
        // Suppose we aren't able to fetch an account and we don't have one stored,
        // despite being logged in --> this should be considered a failed login.
        do {
            let account = try await AuthManager.retrieveAccount()
            Account.current = account
            await saveAndUpdatePreferences(account)
            
            // Support legacy UserDBManager
            await withCheckedContinuation { continuation in
                UserDBManager.shared.syncUserSettings { _ in
                    continuation.resume()
                }
            }
        } catch {
            if !Account.isLoggedIn {
                FirebaseAnalyticsManager.shared.trackEvent(action: "Attempt Login", result: "Failed Login", content: "Failed on Mobile Backend Account Fetch")
                self.state = .loggedOut
            }
        }
        
        self.determineInitialState()
    }
    
    func handlePlatformDefaultLogin() {
        let account = Account(pennid: 12345678, firstName: "Ben", lastName: "Franklin", username: "bfranklin", email: "benfrank@wharton.upenn.edu", student: Student(major: [], school: []), groups: [], emails: [])
        state = .loggedIn(account)
        Account.current = account
    }
    

    @MainActor func determineInitialState() {
        // Pretty sure guest mode doesn't persist, it probably should
        guard self.state != .guest else {
            return
        }
        
        if let account = Account.current, !AuthManager.shouldRequireLogin() {
            self.state = .loggedIn(account)
        } else {
            self.state = .loggedOut
            // Clear preferences iff Account.current == nil (to maintain state)
            if !Account.isLoggedIn {
                AuthManager.clearAccountData()
            }
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
        LabsPlatform.shared?.logoutPlatform()
        AuthManager.clearAccountData()
        print("Cleared all user data")
    }
    
    
    static func retrieveAccount() async throws -> Account {
        let url = URL(string: "https://platform.pennlabs.org/accounts/me/")!
        let request = try await URLRequest(url: url, mode: .accessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkingError.serverError
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let user = try decoder.decode(Account.self, from: data)
        return user
    }
    
    
    func saveAndUpdatePreferences(_ account: Account) async {
        UserDefaults.standard.set(isInWharton: account.isInWharton)
        UserDBManager.shared.saveAccount(account) { (accountID) in
            guard let accountID else {
                return
            }
            
            UserDefaults.standard.set(accountID: accountID)
            if account.isStudent {
                if UserDefaults.standard.getPreference(for: .collegeHouse) {
                    CampusExpressNetworkManager.instance.updateHousingData()
                }
                Account.getDiningTransactions()
                Account.getAndSaveLaundryPreferences()
                Account.getAndSaveFitnessPreferences()
                Account.getPacCode()
            }
        }
    }
}

extension AuthState: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .loggedOut:
            "Logged out"
        case .guest:
            "Guest"
        case .loggedIn(let account):
            "Logged in as \(account.username)"
        }
    }
}
