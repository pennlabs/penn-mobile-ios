//
//  App.swift
//  PennMobile
//
//  Created by Anthony Li on 9/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import Firebase
import SwiftUI
import LabsPlatformSwift

@main
struct PennMobile: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    init() {
        #if DEBUG
            FirebaseConfiguration.shared.setLoggerLevel(.min)
        #endif

        // Register to receive delegate actions from rich notifications
//        UNUserNotificationCenter.current().delegate = delegate
        
        LabsPlatform.initialize(clientId: InfoPlistEnvironment.labsOauthClientId, redirectUrl: "pennmobile://auth")
        LabsPlatform.shared?.delegate = PennMobilePlatformDelegate()
        FirebaseApp.configure()
        
        Task {
//            IncidentsViewModel.shared.startUpdatePolling()
//            try? await IncidentsViewModel.shared.getIncidents()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .accentColor(Color("navigation"))
                .attachLabsPlatform(analyticsRoot: "pennmobile")
        }
    }
}
