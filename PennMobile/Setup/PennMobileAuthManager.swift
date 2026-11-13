//
//  LabsPlatformDelegate.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import LabsPlatformSwift
import PennMobileShared
import SwiftUI

@MainActor
@Observable
class PennMobileAuthManager: LabsPlatformDelegate {
    static let shared = PennMobileAuthManager()
    
    var account: BackendFetchedResult<Account> = PennMobileApplication.Accounts.GetAccount().loadFromCache()
    private var loginGeneration = 0

    func labsPlatformAuth(didUpdateLoggedInState state: (loggedIn: Bool, isDefaultLogin: Bool), platform: LabsPlatform) {
        let loggedIn = state.loggedIn && !state.isDefaultLogin

        // Numbered here, where callbacks are still in order, so the token manager can drop stale ones
        loginGeneration += 1
        let generation = loginGeneration
        Task {
            await NotificationDeviceTokenManager.shared.setLoggedIn(loggedIn, generation: generation)
        }

        if loggedIn {
            Task { @MainActor in
                account = await PennMobileApplication.Accounts.GetAccount().execute()
            }
        }
    }

    // Keeps the cached account on failure, so callers can show it while refreshing
    func refreshAccount() async {
        let result = await PennMobileApplication.Accounts.GetAccount().execute(shouldSilentlyFail: true)
        if case .success = result {
            account = result
        }
    }
}
