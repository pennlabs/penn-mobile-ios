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
    @EnvironmentObject var bannerViewModel: BannerViewModel
    @State var toast: ToastConfiguration?
    @State var toastOffset: Double = 0.0
    @StateObject var popupManager = PopupManager()
    @Environment(\.scenePhase) var scenePhase

    var isOnLogoutScreen: Bool {
        switch authManager.state {
        case .loggedOut:
            true
        default:
            false
        }
    }
    
    let timer = Timer.publish(every: 30, on: .main, in: .default).autoconnect()
    
    var toastExecutor: ToastPresentationCallback {
        return { @MainActor configuration in
            self.toast?.postAccessibilityAnnouncement()
            withAnimation {
                self.toast = configuration
            }
        }
    }
    
    var body: some View {
        Group {
            switch authManager.state {
            case .guest, .loggedIn:
                if bannerViewModel.showBanners {
                    VStack(spacing: 0) {
                        BannerView()
                        MainTabView()
                        BannerView()
                    }
                    .transition(.opacity)
                    .ignoresSafeArea()
                    .sheet(isPresented: $bannerViewModel.showPopup) {
                        UserEngagementPopupView()
                    }
                    .onReceive(timer) { _ in
                        bannerViewModel.showPopup = true
                    }
                } else {
                    MainTabView().transition(.opacity)
                }
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
                    .offset(y: toastOffset)
                    .gesture (
                        DragGesture()
                            .onChanged { drag in
                                // Do not allow the offset to be made positive (go further down the page)
                                toastOffset = drag.translation.height < 0 ? drag.translation.height : 0
                            }
                            .onEnded { drag in
                                // End behavior calculated based on where the gesture ends (top edge of screen).
                                let shouldEnd = drag.location.y < 25
                                if shouldEnd {
                                    withAnimation {
                                        self.toast = nil
                                    }
                                } else {
                                    withAnimation(.snappy) {
                                        toastOffset = 0.0
                                    }
                                }
                            }
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityAction {
                        self.toast = nil
                    }
                    .accessibilityHint("Dismisses the toast")
            }
        }
        .environment(\.presentToast, self.toastExecutor)
        .overlay {
            ZStack {
                if popupManager.disableBackground {
                    Color.white
                        .opacity(0)
                        .edgesIgnoringSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                if popupManager.isShown {
                    CustomPopupView(popupManager: popupManager)
                        .transition(AnyTransition.opacity.combined(with: .scale(scale: 1.05)))
                        .animation(.easeInOut(duration: 0.3), value: popupManager.isShown)
                }
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
        .task {
            ToastView.sharedCallback = self.toastExecutor
        }
        .onChange(of: toast?.id) { _ in
            toastOffset = 0.0
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active && BannerViewModel.isAprilFools {
                bannerViewModel.showBanners = true
            }
        }
    }
}

struct TabBarControllerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> TabBarController {
        return TabBarController()
    }

    func updateUIViewController(_ uiViewController: TabBarController, context: Context) {}
}
