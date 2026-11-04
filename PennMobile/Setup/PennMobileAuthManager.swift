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
    
    func labsPlatformAuth(didUpdateLoggedInState state: (loggedIn: Bool, isDefaultLogin: Bool), platform: LabsPlatform) {
        let loggedIn = state.loggedIn && !state.isDefaultLogin

        Task {
            await NotificationDeviceTokenManager.shared.setLoggedIn(loggedIn)
        }

        if loggedIn {
            Task { @MainActor in
                account = await PennMobileApplication.Accounts.GetAccount().execute()
            }
        }
    }
    
}
