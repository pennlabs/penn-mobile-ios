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
    @State var toast: ToastConfiguration?
    @StateObject var popupManager = PopupManager()

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
                MainTabView().transition(.opacity)
            case .loggedOut:
                LoggedOutView().transition(.opacity)
            default:
                fatalError("Unhandled auth manager state: \(authManager.state)")
            }
        }
        .animation(.default, value: isOnLogoutScreen)
        .overlay(alignment: .top) {
            if let toast {
                ToastView(configuration: toast)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .padding(.top)
            }
        }
        .environment(\.presentToast) { configuration in
            withAnimation {
                toast = configuration
            }
        }
        .overlay {
            if popupManager.isShown {
                CustomPopupView(isShown: $popupManager.isShown,
                                image: popupManager.image,
                                title: popupManager.title,
                                message: popupManager.message,
                                button1: popupManager.button1,
                                button2: popupManager.button2,
                                action1: popupManager.action1,
                                action2: popupManager.action2)
                    .transition(.scale)
            }
        }
        .environmentObject(popupManager)
        .task(id: toast?.id) {
            if toast != nil {
                try? await Task.sleep(for: .seconds(5))
                if !Task.isCancelled {
                    withAnimation {
                        toast = nil
                    }
                }
            }
        }
    }
}
