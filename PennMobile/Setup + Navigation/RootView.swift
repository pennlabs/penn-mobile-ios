//
//  RootView.swift
//  PennMobile
//
//  Created by Anthony Li on 4/23/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authCoordinator: AuthCoordinator
    
    var body: some View {
        Group {
            switch authCoordinator.authState {
            case .authenticated, .guest:
                MainNavigationView()
                .transition(.opacity)
            case .loggingIn:
                VStack {
                    Text("Log in")
                    Button("Continue as guest") {
                        withAnimation {
                            authCoordinator.authState = .guest
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity)
            }
        }
    }
}
