//
//  RootView.swift
//  PennMobile
//
//  Created by Anthony Li on 9/17/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Combine

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var bannerViewModel: BannerViewModel
    @State var toast: ToastConfiguration?
    @State var toastOffset: Double = 0.0
    @StateObject var popupManager = PopupManager()
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @State private var currentShare: GSRShareModel?
    @State private var showShareDetail = false
    @State private var cancellables = Set<AnyCancellable>()

    
    var isOnLogoutScreen: Bool {
        switch authManager.state {
        case .loggedOut:
            true
        default:
            false
        }
    }
    
    let timer = Timer.publish(every: 30, on: .main, in: .default).autoconnect()
    
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
        .onAppear {
           if let alreadyResolved = deepLinkManager.lastResolvedLink {
               currentShare = alreadyResolved
               showShareDetail = true
           }
           deepLinkManager.$lastResolvedLink
               .sink { shareModel in
                   guard let share = shareModel else { return }
                   currentShare = share
                   showShareDetail = true
               }
               .store(in: &cancellables)
        }
        .sheet(isPresented: $showShareDetail) {
           if let model = currentShare {
               GSRShareDetailView(model: model)
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
        .environment(\.presentToast) { configuration in
            toast?.postAccessibilityAnnouncement()
            withAnimation {
                toast = configuration
            }
        }
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
