//
//  App.swift
//  PennMobile
//
//  Created by Anthony Li on 9/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import Firebase
import SwiftUI

@main
struct PennMobile: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    @ObservedObject var authManager = AuthManager()
    @ObservedObject var homeViewModel = StandardHomeViewModel()

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

        FirebaseApp.configure()

        authManager.determineInitialState()

        ControllerModel.shared.prepare()
        LaundryNotificationCenter.shared.prepare()
        GSRLocationModel.shared.prepare()
        LaundryAPIService.instance.prepare {}
        UserDBManager.shared.loginToBackend()

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
            #if DEBUG
                .environmentObject(mockHomeViewModel)
            #endif
                .accentColor(Color("navigation"))
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
