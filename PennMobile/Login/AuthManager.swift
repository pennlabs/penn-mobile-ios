//
//  AuthManager.swift
//  PennMobile
//
//  Created by Anthony Li on 9/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import LabsPlatformSwift

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
        if !Account.isLoggedIn {
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
        Account.clear()
    }
    
    func handlePlatformLogin(res: Bool) async {
        guard res else {
            self.state = .loggedOut
            return
        }
        
        UserDefaults.standard.setLastLogin()
        guard let account = await AuthManager.retrieveAccount() else {
            self.state = .loggedOut
            return
        }
        
        saveAndUpdatePreferences(account)
        
        UserDBManager.shared.syncUserSettings { (_) in
            DispatchQueue.main.async {
                Account.saveAccount(account)
                self.determineInitialState()
            }
        }
    }
    
    func handlePlatformDefaultLogin() {
        let account = Account(pennid: 12345678, firstName: "Ben", lastName: "Franklin", username: "bfranklin", email: "benfrank@wharton.upenn.edu", student: Student(major: [], school: []), groups: [], emails: [])
        state = .loggedIn(account)
        Account.saveAccount(account)
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
        LabsPlatform.shared?.logoutPlatform()
        
        AuthManager.clearAccountData()
    }
    
    
    static func retrieveAccount() async -> Account? {
        let url = URL(string: "https://platform.pennlabs.org/accounts/me/")!
        guard let request = try? await URLRequest(url: url, mode: .accessToken) else {
            return nil
        }

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let user = try? decoder.decode(Account.self, from: data)
        return user
    }
    
    
    func saveAndUpdatePreferences(_ account: Account) {
        UserDefaults.standard.set(isInWharton: account.isInWharton)
        UserDBManager.shared.saveAccount(account) { (accountID) in
            guard let accountID else { return }
            UserDefaults.standard.set(accountID: accountID)
            if account.isStudent {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
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
