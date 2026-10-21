//
//  App.swift
//  PennMobile
//
//  Created by Anthony Li on 9/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

//import Firebase
import SwiftUI
import LabsPlatformSwift
import PennMobileShared

@main
struct PennMobile: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    init() {
        let lightweightLaunchForPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        
//        if !lightweightLaunchForPreview {
//            #if DEBUG
//            FirebaseConfiguration.shared.setLoggerLevel(.min)
//            #endif
//            
//            FirebaseApp.configure()
//        }

        // Register to receive delegate actions from rich notifications
//        UNUserNotificationCenter.current().delegate = delegate
        
        LabsPlatform.initialize(clientId: InfoPlistEnvironment.labsOauthClientId, redirectUrl: "pennmobile://auth")
        LabsPlatform.shared?.delegate = PennMobilePlatformDelegate()
        
        
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
                .attachToastPresentationManager()
        }
    }
}

#Preview {
    RootView()
        .accentColor(Color("navigation"))
        .attachLabsPlatform(analyticsRoot: "pennmobile")
        .attachToastPresentationManager()
}

