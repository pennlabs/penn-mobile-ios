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

@Observable
class PennMobileAuthManager: LabsPlatformDelegate {
    static let shared = PennMobileAuthManager()
    
    var account: BackendFetchedResult<Account> = PennMobileApplication.Accounts.GetAccount().loadFromCache()
    
    func labsPlatformAuth(didUpdateLoggedInState state: (loggedIn: Bool, isDefaultLogin: Bool), platform: LabsPlatform) {
        let (loggedIn, isDefaultLogin) = state
        if loggedIn && !isDefaultLogin {
            Task { @MainActor in
                account = await PennMobileApplication.Accounts.GetAccount().execute()
            }
            // probably do some stuff with notification tokens
        }
        
        // if logged out remove stale caches and reset state
    }
    
}
