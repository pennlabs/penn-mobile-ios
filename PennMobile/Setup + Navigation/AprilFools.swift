//
//  AprilFools.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/22/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared
import CoreMotion
import LabsPlatformSwift
import Combine

struct AprilFoolsViewModifier: ViewModifier {
    
    @StateObject var coreMotionRotationViewModel: CoreMotionRotationViewModel
    @ObservedObject var bannerViewModel: BannerViewModel
    
    //let timer = Timer.publish(every: 30, on: .main, in: .default).autoconnect()
    
    init?() {
        let enabled = (Calendar.isAprilFools || FeatureFlags.shared.forceAprilFoolsRotation)
        guard enabled else { return nil }
        
        self._coreMotionRotationViewModel = StateObject(wrappedValue: CoreMotionRotationViewModel() ?? .init(enabled: false))
        self._bannerViewModel = ObservedObject(wrappedValue: BannerViewModel.shared)
    }
    
    func body(content: Content) -> some View {
        Group {
            VStack(spacing: 0) {
                BannerView()
                    .frame(width: UIScreen.main.bounds.width)
                content
                BannerView()
                    .frame(width: UIScreen.main.bounds.width)
            }
            .transition(.opacity)
            .ignoresSafeArea()
//            .sheet(isPresented: $bannerViewModel.showPopup) {
//                UserEngagementPopupView()
//            }
//            .onReceive(timer) { _ in
//                bannerViewModel.showPopup = true
//            }
        }
        .overlay {
            if coreMotionRotationViewModel.enabled &&
                !coreMotionRotationViewModel.isFaceDown {
                ZStack {
                    Color.white
                        .ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image("KhoiAprilFools")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(.rect(cornerRadius: 16))
                        Text("Flip Your Phone")
                            .font(.title.bold())
                        Text("Penn Mobile must be used face down.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: coreMotionRotationViewModel.isFaceDown)
    }
}

@MainActor class CoreMotionRotationViewModel: ObservableObject {
    let mgr: CMMotionManager?
    @Published var isFaceDown: Bool = false
    let enabled: Bool
    
    init?() {
        self.mgr = CMMotionManager()
        guard (self.mgr?.isDeviceMotionAvailable ?? false) else { return nil }
        self.enabled = true
        self.mgr?.deviceMotionUpdateInterval = 1 / 60
        self.mgr?.startDeviceMotionUpdates(to: .main) { motion, error in
            guard let motion else { return }
            // gravity.z > 0 means the screen is facing down
            self.isFaceDown = motion.gravity.z > 0.7
        }
    }
    
    // Required as a fallback to the failable initializer
    init(enabled: Bool) {
        self.enabled = enabled
        self.mgr = nil
    }
    
    deinit {
        self.mgr?.stopDeviceMotionUpdates()
    }
}

extension View {
    func applyAprilFools() -> some View {
        if let mod = AprilFoolsViewModifier() {
            AnyView(self.modifier(mod))
        } else {
            AnyView(self)
        }
    }
}



