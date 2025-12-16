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
    @ObservedObject var authManager = AuthManager()
    @ObservedObject var homeViewModel = StandardHomeViewModel()
    
    /// Deep link manager for GSR Share
    @StateObject var deepLinkManager = DeepLinkManager()

    #if DEBUG
    @ObservedObject var mockHomeViewModel = MockHomeViewModel()
    #endif

    init() {
        UserDefaults.standard.set(gsrGroupsEnabled: false)

        #if DEBUG
            FirebaseConfiguration.shared.setLoggerLevel(.min)
            UserDefaults.standard.set(gsrGroupsEnabled: true)
        #endif

        // Register to receive delegate actions from rich notifications
        UNUserNotificationCenter.current().delegate = delegate

        authManager.determineInitialState()
        
        FirebaseApp.configure()

        LaundryNotificationCenter.shared.prepare()
        GSRLocationModel.shared.prepare()
        OldLaundryAPIService.instance.prepare {}

        migrateDataToGroupContainer()
        
        let state = authManager.state
        Task {
            await NotificationDeviceTokenManager.shared.authStateDetermined(state)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .environmentObject(homeViewModel)
                .environmentObject(BannerViewModel.shared)
                .environmentObject(deepLinkManager)
                .onOpenURL { url in
                    deepLinkManager.handleOpenURL(url)
                }
            #if DEBUG
                .environmentObject(mockHomeViewModel)
            #endif
                .accentColor(Color("navigation"))
                .enableLabsPlatform(analyticsRoot: "pennmobile",
                                    clientId: InfoPlistEnvironment.labsOauthClientId,
                                    redirectUrl: "https://pennlabs.org/pennmobile/ios/callback/",
                                    defaultLoginHandler: authManager.handlePlatformDefaultLogin,
                                    authManager.handlePlatformLogin)
        }
        .onChange(of: authManager.state.isLoggedIn) {
            homeViewModel.clearData()
        }
        .onChange(of: authManager.state) { state in
            Task {
                await NotificationDeviceTokenManager.shared.authStateDetermined(state)
            }
        }
    }
}
