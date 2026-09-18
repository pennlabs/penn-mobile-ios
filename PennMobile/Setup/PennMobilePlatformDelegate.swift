//
//  LabsPlatformDelegate.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import LabsPlatformSwift

class PennMobilePlatformDelegate: LabsPlatformDelegate {
    func labsPlatformAuth(didUpdateLoggedInState state: (loggedIn: Bool, isDefaultLogin: Bool), platform: LabsPlatform) {
        let (loggedIn, isDefaultLogin) = state
        if loggedIn && !isDefaultLogin {
            // probably do some stuff with notification tokens
        }
        
        // if logged out remove stale caches and reset state
    }
}
