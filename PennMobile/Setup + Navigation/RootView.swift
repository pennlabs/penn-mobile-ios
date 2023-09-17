//
//  RootView.swift
//  PennMobile
//
//  Created by Anthony Li on 9/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager

    var isOnLogoutScreen: Bool {
        switch authManager.state {
        case .loggedOut:
            true
        default:
            false
        }
    }

    var body: some View {
        Group {
            switch authManager.state {
            case .guest, .loggedIn:
                NavigationView {
                    TabBarControllerView()
                        .edgesIgnoringSafeArea(.all)
                }
                    .transition(.opacity)
            case .loggedOut:
                LoggedOutView()
                    .transition(.opacity)
            default:
                fatalError("Unhandled auth manager state: \(authManager.state)")
            }
        }
        .animation(.default, value: isOnLogoutScreen)
    }
}

struct TabBarControllerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> TabBarController {
        return TabBarController()
    }

    func updateUIViewController(_ uiViewController: TabBarController, context: Context) {}
}
