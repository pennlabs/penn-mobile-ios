//
//  NotificationDeviceTokenManager.swift
//  PennMobile
//
//  Created by Anthony Li on 11/18/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import PennMobileShared

// This needs a bit of explanation:
//
// First, there are two distinct parts to notification tokens: receiving the token from
// APNs, and uploading it (as an AUTHENTICATED user) to mobile backend.
//
// We need a way to ensure that the upload step takes place only after we've both
// received a token and been marked as logged in. That's why this is an actor.
// The two functions `tokenReceived` and `setLoggedIn` are receivers, so-to-speak
// for two different delegate methods (one in AppDelegate and the other in PennMobileAuthManager).
// They each check to see if the other one has fired and will fire the "uploadIfReady" if they are
// second.
//
// That's why this is an actor; we need a way to isolate the state to make sure that we protect mutable state
// since it WILL be modified concurrently.
actor NotificationDeviceTokenManager {
    static let shared = NotificationDeviceTokenManager()

    private let store = UserDefaults(suiteName: "group.org.pennlabs.PennMobile")
    private let cachedNotificationTokenKey = "PennMobileNotificationKey"
    private var isLoggedIn = false

    private var cachedToken: Data? { store?.data(forKey: cachedNotificationTokenKey) }

    func tokenReceived(_ token: Data) async {
        let old = cachedToken
        guard token != old else { return }
        store?.set(token, forKey: cachedNotificationTokenKey)

        if let old {
            await PennMobileApplication.Notifications.DeleteDeviceToken(token: old).execute(shouldSilentlyFail: true)
        }
        await uploadIfReady()
    }

    func setLoggedIn(_ loggedIn: Bool) async {
        isLoggedIn = loggedIn

        if loggedIn {
            await uploadIfReady()
        } else if let token = cachedToken {
            await PennMobileApplication.Notifications.DeleteDeviceToken(token: token).execute(shouldSilentlyFail: true)
        }
    }

    private func uploadIfReady() async {
        // This will run every time, but I checked mobile backend and re-uploading the same token shouldn't
        // be a problem.
        guard isLoggedIn, let token = cachedToken else { return }
        let res = await PennMobileApplication.Notifications.UploadDeviceToken(token: token, isDev: false).execute(shouldSilentlyFail: true)
        switch res {
        case .success(_):
            print("Successfully uploaded notification token.")
        case .failure(let error):
            print("Failed to upload notification token: \(error.localizedDescription)")
        case .pending:
            break
        }
    }
}
